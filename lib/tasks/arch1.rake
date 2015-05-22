namespace :arch1 do
  desc "TODO"
  task loadsubjects: :environment do

    #This task processes the existing subject headings scheme for the borthwick registers into Fedora objects
    #Creates a Collection object for 'subjects' (unless it already exists)
    #Creates a ConceptScheme object for the scheme (unless it already exists)
    #Creates Subject Headings objects for each subject using the noid template (ie. unique pids)
    #Updates subject headings with broader and narrower terms

    require 'open-uri'
    require 'nokogiri'

    f = File.open("/home/geekscruff/tmp/subjects.xml")
    @doc = Nokogiri::XML(f)
    f.close

    #@doc = Nokogiri::XML(open('http://dlib.york.ac.uk/ontologies/borthwick/subjects.xml')) do |config|
    #  config.strict.nonet
    #end

    @subs_id = 'subjects'
    @scheme_id = 'york:borthwick-registers-subject-headings'
    @cons_id = 'concepts'

    begin
      puts 'Creating the Subjects collection'
      c = Collection.new(@subs_id)
      c.title = 'Subjects'
      c.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable']
      c.save
      c.identifier = c.id
      c.save
      c.update_index
    rescue
      puts 'Subjects collection exists, skipping to next step'
    end

    puts 'Creating the Subjects Scheme'

    @scheme # the scheme (parent) record id
    @concepts #the concepts container
    @subjects = {} # subject record ids
    begin
      @scheme = ConceptScheme.new(@subs_id + '/' + @scheme_id)
      @scheme.title = @doc.css('rdf|description rdf|label').text
      @scheme.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable', 'http://www.w3.org/2004/02/skos/core#ConceptScheme']
      @scheme.save
      @scheme.identifier = @scheme.id.split('/').last
      @scheme.save
      @scheme.update_index
    rescue
      puts 'Scheme exists, assigning to local variable'
      @scheme = ConceptScheme.where(id: @subs_id + '/' + @scheme_id).first
    end

    begin
      puts 'Creating the Concepts Container'
      @concepts = Collection.new(@subs_id + '/' + @scheme_id + '/' + @cons_id)
      @concepts.title = 'Concepts'
      @concepts.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable']
      # add a ldp:DirectContainer directly in Fedora; doing it here does not add the mixin type
      # direct contains support is coming in AF I am bleeding edge!
      # Oh, I don't really think this is necessary now
      #@concepts.memresource = @scheme
      #@concepts.memrelation = 'http://www.w3.org/2004/02/skos/core#inScheme'
      @concepts.save
      @concepts.identifier = c.id.split('/').last
      @concepts.save
      @concepts.update_index
    rescue
      puts $!
      puts 'Concepts collection exists, skipping to next step'
      @concepts = Collection.where(id: @subs_id + '/' + @scheme_id + '/' + @cons_id).first
    end

    puts 'Processing subject headings. This may take some time ... '

    @doc.css('rdf|description').each do |i|
      if i.css('skos|prefLabel').text != ''
        h = Concept.new
        h.set_id_path(@subs_id + '/' + @scheme_id + '/' + @cons_id)
        h.concept_scheme = @scheme
        h.rdftype += ['http://www.w3.org/2004/02/skos/core#Concept', 'http://fedora.info/definitions/v4/indexing#Indexable']
        h.preflabel = i.css('skos|prefLabel').text
        if i.css('skos|altLabel')
          i.css('skos|altLabel').each do |i|
            h.altlabel += [i.text]
          end
        end
        if i.css('skos|definition').text != ''
          h.definition = i.css('skos|definition').text
        end
        h.save
        if i.css('skos|broader').text == ''
          h.istopconcept = 'true'
          @scheme.topconcept += [h]
          @scheme.save
        end
        h.identifier = h.id.split('/').last
        h.former_id = i.values
        h.save
        @subjects[i.values] = h.id
        h.update_index
      end
    end

    puts 'Adding broader and narrower terms. This may take some time ... '

    @doc.css('rdf|description').each_with_index do |i |
      if i.css('skos|prefLabel').text != ''
        m = Concept.where(id: @subjects[i.values]).first
        if i.css('skos|narrower')
          i.css('skos|narrower').each do |i|
            begin
              a = [i.text]
              n = Concept.where(id: @subjects[a]).first
              m.narrower += [n]
            rescue
              puts 'ERROR with adding narrower :',i.text
              puts 'to object pid: ',m.id
            end
          end
        end
        if i.css('skos|broader')
          i.css('skos|broader').each do |i|
            begin
              a = [i.text]
              b = Concept.where(id: @subjects[a]).first
              m.broader = [b]
            rescue
              puts 'ERROR with adding broader :',i.text
              puts 'to object pid: ',m.id
            end
          end
        end
        m.save
        m.update_index
      end
    end
    puts 'Finished!'
  end

  task loadterms: :environment do

    require 'csv'

    list = ['place-types','statuses', 'roles', 'qualifications','folio-faces','folios','currencies','languages','date-types','certainty']

    list.each do | i |

      # let's load the statuses, roles and qualifications

      @subs_id = 'terms'
      @scheme_id = 'york:borthwick-registers-' + i
      @cons_id = 'concepts'

      begin
        puts 'Creating the collection'
        c = Collection.new(@subs_id)
        c.title = 'Subjects'
        c.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable']
        c.save
        c.identifier = c.id
        c.save
        c.update_index
      rescue
        puts 'Subjects collection exists, skipping to next step'
      end

      puts 'Creating the Subjects Scheme'

      @scheme # the scheme (parent) record id
      @concepts #the concepts container
      begin
        @scheme = ConceptScheme.new(@subs_id + '/' + @scheme_id)
        @scheme.title = i
        @scheme.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable', 'http://www.w3.org/2004/02/skos/core#ConceptScheme']
        @scheme.save
        @scheme.identifier = @scheme.id.split('/').last
        @scheme.save
        @scheme.update_index
      rescue
        puts 'Scheme exists, assigning to local variable'
        @scheme = ConceptScheme.where(id: @subs_id + '/' + @scheme_id).first
      end

      begin
        puts 'Creating the Concepts Container'
        @concepts = Collection.new(@subs_id + '/' + @scheme_id + '/' + @cons_id)
        @concepts.title = 'Concepts'
        @concepts.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable']
        @concepts.save
        @concepts.identifier = c.id.split('/').last
        @concepts.save
        @concepts.update_index
      rescue
        puts $!
        puts 'Concepts collection exists, skipping to next step'
        @concepts = Collection.where(id: @subs_id + '/' + @scheme_id + '/' + @cons_id).first
      end

      puts 'Processing ' + i + '. This may take some time ... '

      arr = CSV.read("/home/geekscruff/tmp/abs/" + i + ".csv")
      arr = arr.uniq

      arr.each_with_index do | c, index |
        puts index.to_s + ' of ' + arr.length.to_s
        c.each do | b |
          h = Concept.new
          h.set_id_path(@subs_id + '/' + @scheme_id + '/' + @cons_id)
          h.concept_scheme = @scheme
          h.rdftype += ['http://www.w3.org/2004/02/skos/core#Concept', 'http://fedora.info/definitions/v4/indexing#Indexable']
          h.preflabel = b.strip
          h.save
          h.identifier = h.id.split('/').last
          h.save
          h.update_index

        end
      end

    end

  end
end
