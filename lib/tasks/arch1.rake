namespace :arch1 do
  desc "TODO"
  task loadsubjects: :environment do

    #This task processes the existing subject headings scheme for the borthwick registers into Fedora objects
    #Creates a ConceptScheme object for the scheme
    #Creates Subject Headings objects
    #Updates subject headings with broader and narrower terms

    # If it fails to complete (java heap space error in fedora), it's setup to recover,
    # the only manual step is to comment out as indicated below and and add in a where query
    # for the correct fedora object

    require 'open-uri'
    require 'nokogiri'
    require 'csv'

    puts 'Starting ... '

    #for testing
    #f = File.open("/home/geekscruff/tmp/subjects.xml")
    #@doc = Nokogiri::XML(f)
    #f.close

    @doc = Nokogiri::XML(open('http://dlib.york.ac.uk/ontologies/borthwick/subjects.xml')) do |config|
      config.strict.nonet
    end

    puts 'Creating the Subjects Scheme'

    #@path = '/home/geekscruff/Dropbox/code/rails/arch1/lib/tasks/' # SET THE PATH
    @path = '/home/py523/rails_projects/arch1/lib/tasks/' # SET THE PATH
    @skip = false # run broader / narrower
    @scheme # the scheme (parent) record id
    @subjects = {} # subject record ids
    begin
      # == COMMENT OUT WHEN RUNNING A RECOVERY ==
      @scheme = ConceptScheme.new
      @scheme.title = @doc.css('rdf|description rdf|label').text
      @scheme.description = @doc.css('rdf|description rdf|label').text + ". Produced from data created during the Archbishop's Registers Pilot project, funded by the Mellon Foundation."
      @scheme.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable', 'http://www.w3.org/2004/02/skos/core#ConceptScheme']
      @scheme.save
      @scheme.identifier = @scheme.id
      @scheme.save
      @scheme.update_index
      # == END  ==
      # == UNCOMMENT WHEN RUNNING A RECOVERY AND ADD IN THE RIGHT ID ==
      #@scheme = ConceptScheme.where(id: 'yorkabp:457').first
      # == END  ==
      puts 'Created ' + @scheme.id
    rescue
      puts $!
    end

    puts 'Processing subject headings. This may take some time ... '

    @tmp = {}

    if File.exists?(@path + 'headings.csv')
      f = File.open(@path + 'headings.csv', 'rb')
      @tmp = eval(f.read) # a hash
    end

    # this isn't needed any more but can be useful if you lose the headings list
    # generate a list from a solr query, turn into an array
    # arr = CSV.read(@path + 'headings1.csv')
    # arr.each do | key, value |
    #   @tmp[[key]] = value
    # end

    begin
      f = File.open(@path + 'headings.csv', 'w')
      @doc.css('rdf|description').each do |i|
        if i.css('skos|prefLabel').text != ''
          if @tmp != nil and @tmp.has_key?(i.values)
            @subjects[i.values] = @tmp[i.values]
            #puts 'skipping ' + @tmp[i.values]
          else

            h = Concept.new
            h.rdftype += ['http://www.w3.org/2004/02/skos/core#Concept', 'http://fedora.info/definitions/v4/indexing#Indexable']
            h.preflabel = i.css('skos|prefLabel').text
            h.concept_scheme = @scheme
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
            h.identifier = h.id
            h.former_id = i.values
            h.save
            h.update_index
            @subjects[i.values] = h.id

          end
        end
      end
    rescue
      f.write(@subjects)
      f.close
      @skip = true
      puts $!
    end

    # need them in case bn fails
    f.write(@subjects)
    f.close

    if @skip == false
      puts 'Adding broader and narrower terms. This may take some time ... '

      @tmp_bn = []

      if File.exists?(@path + 'headings_bn.csv')
        ff = File.open(@path + 'headings_bn.csv', 'rb')
        @tmp_bn = eval(ff.read) # an array
      end

      begin
        ff = File.open(@path + 'headings_bn.csv', 'w')
        @doc.css('rdf|description').each do |i|
          if i.css('skos|prefLabel').text != ''

            if @tmp_bn != nil and @tmp_bn.include?(i.values)
              #puts 'skipping b/n '
            else
              m = Concept.where(id: @subjects[i.values]).first
              if i.css('skos|narrower')
                i.css('skos|narrower').each do |i|
                  begin
                    a = [i.text]
                    n = Concept.where(id: @subjects[a]).first
                    m.narrower += [n]
                  rescue
                    puts 'ERROR with adding narrower :', i.text
                    puts 'to object pid: ', m.id
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
                    puts 'ERROR with adding broader :', i.text
                    puts 'to object pid: ', m.id
                  end
                end
              end
              m.save
              m.update_index
              @tmp_bn += i.values
              puts 'done object: ', m.id
            end
          end
        end
      rescue
        ff.write(@tmp_bn)
        ff.close
        puts $!
      end
    end
    puts 'Finished!'
  end

  task readterms: :environment do

    list = ['folio-faces', 'folios', 'currencies', 'date-types', 'certainty', 'qualifications', 'place-types', 'statuses', 'roles']

    list.each do |l|
      arr = CSV.read('/home/geekscruff/tmp/abs/' + l + '.csv')
      arr = arr.uniq
      arr = arr.sort!

      newarr = []
      arr.each do |i|
        if i[0] != nil
          #remove brackets and question marks, strip out leading / trailing whitespace
          newarr += [i[0].gsub('[', '').gsub(']', '').gsub('?', '').strip]
        end
      end

      f = File.open('/home/geekscruff/Dropbox/code/rails/arch1/lib/tasks/' + l + '.csv', 'w')
      newarr.uniq.each do |i|
        if i != nil
          f.write(i + "\n")
        end
      end

      f.close
    end

  end

  task loadterms: :environment do

    require 'csv'

    #@path = '/home/geekscruff/Dropbox/code/rails/arch1/lib/tasks/' # SET THE PATH
    @path = '/home/py523/rails_projects/arch1/lib/tasks/' # SET THE PATH

    # .csv files should exist in the specified path
    list = ['folio-faces', 'folios', 'currencies', 'date-types', 'certainty', 'qualifications', 'place-types', 'statuses', 'roles', 'formats', 'single-date-types', 'languages']

    list.each do |i|

      if i == 'place-types' or i == 'roles' or i == 'statuses'
        puts 'Sleeping between the long ones'
        sleep 60
      end

      puts 'Creating the Concept Scheme'

      @arr = []
      if File.exists?(@path + i + '_list.csv')
        arr = CSV.read(@path + i + '_list.csv')
        a = File.open(@path + i + '_list_processing.csv', 'w')
        arr.each do |i|
          a.write(i[0] + "\n")
        end
        a.close
        @arr = CSV.read(@path + i + '_list_processing.csv')
      end

      f = File.open(@path + i + '_list.csv', 'w')

      begin

        if @arr != []
          @scheme = ConceptScheme.where(id: @arr[0]).first
          puts @scheme.id + ' exists, using it'

        else

          @scheme = ConceptScheme.new
          @scheme.title = i
          @scheme.description = 'Terms for ' + i + " produced from data created during the Archbishop's Registers Pilot project, funded by the Mellon Foundation."
          @scheme.rdftype += ['http://fedora.info/definitions/v4/indexing#Indexable', 'http://www.w3.org/2004/02/skos/core#ConceptScheme']
          @scheme.save
          @scheme.identifier = @scheme.id
          @scheme.save
          @scheme.update_index
          f.write(@scheme.id + "\n")

        end
      rescue
        puts $!
      end

      puts 'Processing ' + i + '. This may take some time ... '

      arr = CSV.read(@path + i + '.csv')
      arr = arr.uniq

      arr.each_with_index do |c, index|
        c.each do |b|
          begin

            if i == 'place-types' or i == 'roles' or i == 'statuses'
              sleep 5
              puts index
            end

            if @arr != []
              if @arr.include? [b.strip]
                puts 'skipping ' + b.strip
              else
                h = Concept.new
                h.rdftype += ['http://www.w3.org/2004/02/skos/core#Concept', 'http://fedora.info/definitions/v4/indexing#Indexable']
                h.preflabel = b.strip
                h.concept_scheme = @scheme
                h.save
                h.identifier = h.id
                h.save
                h.update_index
                f.write(h.preflabel + "\n")
              end
            else
              h = Concept.new
              h.rdftype += ['http://www.w3.org/2004/02/skos/core#Concept', 'http://fedora.info/definitions/v4/indexing#Indexable']
              h.preflabel = b.strip
              h.concept_scheme = @scheme
              h.save
              h.identifier = h.id
              h.save
              h.update_index
              f.write(h.preflabel + "\n")
            end
          rescue
            f.close
            puts $!
          end
        end
      end
      f.close
      File.delete(@path + i + '_list.csv')
    end
    puts 'Finished!'
  end

=begin
  task loadregsfolios: :environment do

    path = '/home/geekscruff/Dropbox/code/rails/arch1/'

    f = File.open(path + 'app/assets/files/folio_list.txt', "r")

    @register = Register.new
    @register.rdftype = @register.add_rdf_types
    @register.reg_id = 'Abp Reg 12'
    @register.save

    @foltype = FolioTerms.new('subauthority')
    @face = FolioFaceTerms.new('subauthority')

    @folios = []

    puts 'Processing lines to create folios and images'

    #count = 0

    f.each_line do |ln|
      #count += 1
      #if count < 10 # testrun
      l = ln
      l = l.downcase.sub!('reg_12_', '')
      fol = Folio.new
      fol.rdftype = fol.add_rdf_types
      fol.save
      image = Image.new
      image.folio = fol
      image.rdftype = image.add_rdf_types
      image.motivated_by = 'http://www.shared-canvas.org/ns/painting'
      image.file = '/usr/digilib-webdocs/digilibImages/ArchbishopsRegisters/reg12/JP2/' + ln.sub("\r", '').sub("\n", '')
      image.save
      fol.images += [image]
      fol.register = @register
      @register.folios += [fol]
      @register.has_member += [fol.id] #id or not to id, see also next / prev (USING IDs)
      @register.save
      @register.update_index

      if l.include? 'insert'
        fol.folio_type = @foltype.find_id('insert')

        l = l.sub('insert', '')
      else
        fol.folio_type = @foltype.find_id('folio')
      end

      if l.include? 'recto'
        fol.folio_face = @face.find_id('recto')
        l = l.sub!('recto', '')
      elsif l.include? 'verso'
        fol.folio_face = @face.find_id('verso')
        l = l.sub('verso', '')
      else
        fol.folio_face = @face.find_id('undefined')
      end

      l = l.sub('.jp2', '').sub(' ', '').sub('__', '').sub('_', '').sub("\r", '').sub("\n", '')
      fol.folio_no = l

      fol.save

      @folios += [fol.id]
      #end

    end

    puts 'Adding proxies'

    @folios.each_with_index do |p, index|

      if index == 0
        @register.fst = Folio.where(id: p).first.id
        @register.save
      elsif index == @folios.length - 1
        @register.lst = Folio.where(id: p).first.id
        @register.save
      else
        pox = Proxy.new
        pox.rdftype = pox.add_rdf_types
        pox.folios += [Folio.where(id: p).first]
        pox.next = Folio.where(id: @folios[index+1]).first.id
        pox.prev = Folio.where(id: @folios[index-1]).first.id
        pox.register = @register
        pox.save
      end

    end

    puts 'Finished'

  end
=end

end
