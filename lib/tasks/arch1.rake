namespace :arch1 do

  desc "TODO"


# NOTE: when running loadsubjects, lib/assets/lists must exist otherwise a write error occurs
  task loadsubjects: :environment do

    start_time = Time.now

    @skip = false

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

    @doc = Nokogiri::XML(open('http://dlib.york.ac.uk/ontologies/borthwick/subjects.xml')) do |config|
      config.strict.nonet
    end

    puts 'Creating the Subjects Scheme'

    @path = Rails.root + 'lib/assets/lists/'
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

        count = 0

        @doc.css('rdf|description').each do |i|

          if i.css('skos|prefLabel').text != ''

            count = count + 1

            puts "count = #{count}"
            puts i.css('skos|prefLabel').text

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
              #@tmp_bn += i.values
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

    puts "End Time:"
    puts (Time.now - start_time)

  end

  task readterms: :environment do

    list = ['folio_faces', 'folio_types', 'currencies', 'certainty',
            'place_types', 'descriptors', 'roles', 'place_roles', 'date_roles', 'single_dates']

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

    path = Rails.root + 'lib/'

    # .csv files should exist in the specified path but remove any list_processing.csv files if starting afresh
    list = ['folio_faces', 'folio_types', 'currencies', 'certainty', 'languages',
            'place_types', 'descriptors', 'person_roles', 'place_roles', 'date_roles', 'single_dates', 'entry_types']

    list.each do |i|

      puts 'Creating the Concept Scheme'

      @arr = []
      if File.exists?(path + "tasks/#{i}_list.csv")
        arr = CSV.read(path + "tasks/#{i}_list.csv")
        a = File.open(path + "tasks/#{i}_list_processing.csv", "w")
        arr.each do |i|
          a.write(i[0] + "\n")
        end
        a.close
        @arr = CSV.read(path + "tasks/#{i}_list_processing.csv")
      end

      f = File.open(path + "tasks/#{i}_list.csv", "w")

      begin

        if @arr != []
          @scheme = ConceptScheme.where(id: @arr[0]).first
          puts @scheme.id + ' exists, using it'

        else
          @scheme = ConceptScheme.new
          @scheme.title = i
          @scheme.description = "Terms for #{i} produced from data created during the Archbishop's Registers Pilot project, funded by the Mellon Foundation."
          @scheme.rdftype = @scheme.add_rdf_types
          @scheme.save
          puts @scheme.id
          f.write(@scheme.id + "\n")

        end
      rescue
        puts $!
      end

      puts 'Processing ' + i + '. This may take some time ... '

      arr = CSV.read(path + "tasks/#{i}.csv")
      arr = arr.uniq

      arr.each do |c|
        c.each do |b|
          begin

            if @arr != []
              if @arr.include? [b.strip]
                puts 'skipping ' + b.strip
              else
                h = Concept.new
                h.rdftype = h.add_rdf_types
                h.preflabel = b.strip
                h.concept_scheme = @scheme
                h.save
                h.identifier = h.id
                h.save
                f.write(h.preflabel + "\n")
              end
            else
              h = Concept.new
              h.rdftype += h.add_rdf_types
              h.preflabel = b.strip
              h.concept_scheme = @scheme
              h.save
              f.write(h.preflabel + "\n")
            end
          rescue
            f.close
            puts $!
          end
        end
      end
      f.close
      File.delete(path + "tasks/#{i}_list.csv")
    end
    puts 'Finished!'
  end

   # This is superseded loadallrf
=begin
  task loadregsfolios: :environment do

    require 'json'

    path = Rails.root

    f = File.open(path + 'app/assets/files/folio_list.txt', "r")

    @register = Register.new
    @register.rdftype = @register.add_rdf_types
    @register.reg_id = 'Abp Reg 12'
    @register.save

    @foltype = FolioTerms.new('subauthority')
    @face = FolioFaceTerms.new('subauthority')

    @folios = []

    puts 'Processing lines to create folios and images'

    count = 0

    f.each_line do |ln|

      count += 1
      puts count

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
      image.file = '/usr/digilib-webdocs/digilibImages/ArchbishopsRegisters/reg12/JP2/' + ln.sub(' ', '_').sub("\r", '').sub("\n", '')
      image.save
      fol.images += [image]
      fol.register = @register
      @register.folios += [fol]
      @register.has_member += [fol.id] #id or not to id, see also next / prev (USING IDs)
      @register.save

      if l.include? 'insert'
        fol.folio_type = @foltype.find_id('insert')

        l = l.sub('insert', '')
      else
        fol.folio_type = @foltype.find_id('folio')
        puts "folio type = #{fol.folio_type}"
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

      pox = Proxy.new
      pox.rdftype = pox.add_rdf_types
      pox.folios += [Folio.where(id: p).first]

      if index == 0
        pox.next = Folio.where(id: @folios[index+1]).first.id
        @register.fst = pox.id
        @register.save
      elsif index == @folios.length - 1
        pox.prev = Folio.where(id: @folios[index-1]).first.id
        @register.lst = Folio.where(id: p).first.id
        @register.save
      else
        pox.next = Folio.where(id: @folios[index+1]).first.id
        pox.prev = Folio.where(id: @folios[index-1]).first.id
      end
      pox.register = @register
      pox.save

    end

    puts 'Finished'

  end
=end

  # Need xml.tar to be expanded in lib/assets/folios for this to work
  task loadallrf: :environment do

    path = Rails.root + 'lib/assets/'

    f = File.open(path + 'registers/registers.json', 'r')

    hash = JSON.parse(f.read)

    hash['response']['docs'].map do |r|

      puts "Processing Register #{r['dc.title']}"

      @register = Register.new
      @register.rdftype = @register.add_rdf_types
      @register.reg_id = r['dc.title'].split(':')[0]
      @register.title = r['dc.title'].split(':')[1]
      @register.former_id = [r['PID']]
      @register.save

      @folios = []

      #repeat this step for the folio file

      l =  r['PID'].split(':')[1] + '.json'

      ff = File.open(path + 'folios/' + l, 'r')

      hash2 = JSON.parse(ff.read)

      hash2['response']['docs'].map do |rr|

        puts "Processing Folio #{rr['dc.title']}"

        @folio = Folio.new
        @folio.title = rr['dc.title'].split(';')[0] # ignore the entry statements in register 12
        @folio.former_id = [rr['PID']]
        @folio.register = @register

        o = rr['dc.title'].split(';')[0].split(' ')
        o.delete_at(0)
        o.delete_at(0)
        o.delete_at(0)
        o.delete('and')
        o.delete('(alternate') #might want to model these a bit differently
        o.delete('version)')
        puts "final o = #{o}"
        o.each do | oo |

          # deal with errors in the data
          if oo == 'rectot'
            oo = 'recto'
          end
          if oo == 'vesro'
            oo = 'verso'
          end
          if oo == 'inse'
            oo = 'insert'
          end
          if oo == 'folio/insert'
            oo = 'insert'
          end

          if FolioTerms.new('subauthority').search(oo.downcase.singularize).to_s.include? oo.downcase.singularize
            FolioTerms.new('subauthority').search(oo.downcase.singularize).map do | ft |
              @folio.folio_type = ft['id']
            end

          elsif FolioFaceTerms.new('subauthority').search(oo.downcase.singularize).to_s.include? oo.downcase.singularize
            FolioFaceTerms.new('subauthority').search(oo.downcase.singularize).map do | ff |
              @folio.folio_face = ff['id']
            end
          else
            @folio.folio_no += [oo.downcase.singularize]
          end

        end

        @folio.save
        @folios += [@folio.id]

        puts 'Adding Image (from xml)'

        image = Image.new
        image.folio = @folio
        image.rdftype = image.add_rdf_types
        image.motivated_by = 'http://www.shared-canvas.org/ns/painting'
        f = File.open(path + "folios/xml/#{rr['PID'].sub('york:','')}.xml")
        @doc = Nokogiri::XML(f)
        f.close
        image.file = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/','/usr/digilib-webdocs/')
        image.save
        @folio.images += [image]

        @register.folios += [@folio]
        @register.has_member += [@folio.id] #id or not to id, see also next / prev (USING IDs)
        @register.save

      end

      puts 'Adding proxies'

      @folios.each_with_index do |p, index|

        pox = Proxy.new
        pox.rdftype = pox.add_rdf_types
        pox.folios += [Folio.where(id: p).first]

        if index == 0
          pox.next = Folio.where(id: @folios[index+1]).first.id
          @register.fst = Folio.where(id: p).first.id
          @register.save
        elsif index == @folios.length - 1
          pox.prev = Folio.where(id: @folios[index-1]).first.id
          @register.lst = Folio.where(id: p).first.id
          @register.save
        else
          pox.next = Folio.where(id: @folios[index+1]).first.id
          pox.prev = Folio.where(id: @folios[index-1]).first.id
        end
        pox.register = @register
        pox.save

      end
    end
  end

  # Temporary code to add people ConceptScheme
  task add_people_concept_scheme: :environment do
    @scheme = ConceptScheme.new
    @scheme.title = 'people'
    @scheme.save
    puts @scheme.id
  end

  # Temporary code to add places ConceptScheme
  task add_places_concept_scheme: :environment do
    @scheme = ConceptScheme.new
    @scheme.title = 'places'
    @scheme.save
    puts @scheme.id
  end

end
