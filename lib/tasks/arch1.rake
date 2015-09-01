namespace :arch1 do

  desc "TODO"

  task loadterms: :environment do

    # since this seems to run OK now, I've commented out the 'rescue' stuff

    require 'csv'

    path = Rails.root + 'lib/'

    # .csv files should exist in the specified path
    # removed 'certainty', 'date_types'
    list = ['folio_faces', 'folio_types', 'currencies', 'languages', 'place_types', 'descriptors', 'person_roles', 'place_roles', 'date_roles', 'formats', 'section_types', 'entry_types']
    list.each do |i|

      puts 'Creating the Concept Scheme'

      #@arr = []
      # if File.exists?(path + "assets/lists/#{i}_list.csv")
      #   arr = CSV.read(path + "assets/lists/#{i}_list.csv")
      #   a = File.open(path + "assets/lists/#{i}_list_processing.csv", "w")
      #   arr.each do |i|
      #     a.write(i[0] + "\n")
      #   end
      #   a.close
      #   @arr = CSV.read(path + "assets/lists/#{i}_list_processing.csv")
      # end
      #
      # f = File.open(path + "assets/lists/#{i}_list.csv", "w")

      begin

        # if @arr != []
        #   @scheme = ConceptScheme.where(id: @arr[0]).first
        #   puts @scheme.id + ' exists, using it'
        #
        # else
        @scheme = ConceptScheme.new
        @scheme.preflabel = i
        @scheme.description = "Terms for #{i} produced from data created during the Archbishop's Registers Pilot project, funded by the Mellon Foundation."
        @scheme.rdftype = @scheme.add_rdf_types
        @scheme.save
        puts @scheme.id
          #f.write(@scheme.id + "\n")
          #end
      rescue
        puts $!
      end

      puts 'Processing ' + i + '. This may take some time ... '

      arr = CSV.read(path + "assets/lists/#{i}.csv")
      arr = arr.uniq # remove any duplicates

      arr.each do |c|
        c.each do |b|
          begin

            # if @arr != []
            #   if @arr.include? [b.strip]
            #     puts 'skipping ' + b.strip
            #   else
            #     h = Concept.new
            #     h.rdftype = h.add_rdf_types
            #     h.preflabel = b.strip
            #     h.concept_scheme = @scheme
            #     h.save
            #     h.identifier = h.id
            #     h.save
            #     f.write(h.preflabel + "\n")
            #   end
            # else
            h = Concept.new
            h.rdftype += h.add_rdf_types
            h.preflabel = b.strip
            h.concept_scheme = @scheme
            h.save
              #f.write(h.preflabel + "\n")
              #end
          rescue
            #f.close
            puts $!
          end
        end
      end
      #f.close
      #File.delete(path + "assets/lists/#{i}_list.csv")
    end
    puts 'Finished!'
  end

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
      @scheme.preflabel = @doc.css('rdf|description rdf|label').text
      @scheme.description = @doc.css('rdf|description rdf|label').text + ". Produced from data created during the Archbishop's Registers Pilot project, funded by the Mellon Foundation."
      @scheme.rdftype += ['http://www.w3.org/2004/02/skos/core#ConceptScheme']

        # == END  ==
        # == UNCOMMENT WHEN RUNNING A RECOVERY AND ADD IN THE RIGHT ID ==
        #@scheme = ConceptScheme.where(id: 'yorkabp:457').first
        # == END  ==
        #puts 'Created ' + @scheme.id
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
            h.rdftype += ['http://www.w3.org/2004/02/skos/core#Concept']
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
              begin
                @scheme.topconcept += [h]
                @scheme.concepts += [h]
                @scheme.save
              rescue
                puts $!
              end
            end
            h.identifier = h.id
            h.former_id = i.values
            h.save
            puts h.id
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

    @scheme.save
    @scheme.identifier = @scheme.id

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
                    n = @subjects[a] #Concept.where(id: @subjects[a]).first
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
                    b = @subjects[a] #Concept.where(id: @subjects[a]).first
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

    puts "End Time:"
    puts (Time.now - start_time)

  end


  task loadallrf: :environment do

    require 'json'

    path = Rails.root + 'lib/assets/'

    f = File.read(path + 'registers/registers.json')

    JSON.parse(f)['response']['docs'].map do |r|

      puts "Processing Register #{r["dc.title"]},#{r["PID"]}"

      @register = Register.new
      @register.rdftype = @register.add_rdf_types
      dctitle = r["dc.title"].split(':')
      @register.reg_id = dctitle[0].strip
      @register.preflabel = dctitle[1].strip
      @register.former_id = [r["PID"]]
      @register.save

      @folios = []

      #repeat this step for the folio file

      l = r["PID"].split(':')[1] + '.json'
      puts l
      ff = File.read(path + 'folios/' + l)

      JSON.parse(ff)['response']['docs'].map do |rr|
        puts "Processing Folio #{rr["dc.title"]},#{rr["PID"]}"
        @folio = Folio.new
        dctitle = rr["dc.title"].split(';')
        @folio.preflabel = dctitle[0].strip # ignore the entry statements in register 12
        @folio.former_id = [rr["PID"]]
        @folio.register = @register

        o = dctitle[0].split(' ')
        o.delete_at(0)
        o.delete_at(0)
        o.delete_at(0)
        o.delete('and')
        o.delete('(alternate') #might want to model these a bit differently (deal with these in separate rake task)
        o.delete('version)')
        o.each do |oo|

          # deal with errors in the data as much as possible
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
            # FolioTerms.new('subauthority').search(oo.downcase.singularize).map do | ft |
            #   @folio.folio_type = ft['id']
            # end
            # do nothing, we don't include this any more
          elsif FolioFaceTerms.new('subauthority').search(oo.downcase.singularize).to_s.include? oo.downcase.singularize
            FolioFaceTerms.new('subauthority').search(oo.downcase.singularize).map do |ff|
              @folio.folio_face = ff['id']
            end
          else
            if @folio.folio_no.nil?
              @folio.folio_no = oo.downcase.singularize
            else
              @folio.folio_no += "#{ oo.downcase.singularize}"
            end

          end
        end

        @folio.save
        @folios += [@folio.id]

        puts 'Adding Image (from xml)'

        image = Image.new
        image.folio = @folio
        image.rdftype = image.add_rdf_types
        image.motivated_by = 'http://www.shared-canvas.org/ns/painting'
        f = File.open(path + "folios/xml/#{rr["PID"].sub('york:', '')}.xml")
        @doc = Nokogiri::XML(f)
        f.close
        image.file = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
        image.save
        @folio.images += [image]
        @register.folios += [@folio]
        @folio.save
        #@register.has_member += [@folio.id] #id or not to id, see also next / prev (USING IDs)
        @register.save
      end

      puts 'Adding proxies'

      @folios.each_with_index do |p, index|

        pox = Proxy.new
        pox.rdftype = pox.add_rdf_types
        fol = Folio.where(id: p).first
        pox.folios += [fol]
        fol.proxies += [pox]
        fol.save

        if index == 0
          pox.next = Folio.where(id: @folios[index+1]).first.id
          @register.fst = fol.id
        elsif index == @folios.length - 1
          pox.prev = Folio.where(id: @folios[index-1]).first.id
          @register.lst = fol.id
        else
          pox.next = Folio.where(id: @folios[index+1]).first.id
          pox.prev = Folio.where(id: @folios[index-1]).first.id
        end
        pox.register = @register
        @register.save
        pox.save

      end

      puts 'Finished'
    end
  end

  # this just tidies up some of the register 12 folio names to make life easier when I import the entries
  task tidy12: :environment do

    require 'csv'

    path = Rails.root + 'lib/assets/'

    f = CSV.read(path + 'reg12_folios.csv')

    f.each do |i|
      id = ''
      SolrQuery.new.solr_query("former_id_tesim:#{i[0]}")['response']['docs'].map do |r|
        id = r['id']
      end

      puts 'Processing ' + id
      unless id.nil?
        folio = Folio.where(id: id).first

        unless folio.nil?
          folio.preflabel = i[1]
          folio.folio_no = i[2]
          puts i[2]

          SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"folio_faces"', 'id')['response']['docs'].map do |face|
            begin
              folio.folio_face = SolrQuery.new.solr_query("inScheme_ssim:\"#{face['id']}\" AND preflabel_tesim:#{i[3]}", 'id')['response']['docs'].map.first['id']
            rescue
              # skip folio face
            end
          end
          # SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND title_tesim:"folio_types"','id')['response']['docs'].map do | face |
          #   folio.folio_type = SolrQuery.new.solr_query("inScheme_ssim:\"#{face['id']}\" AND preflabel_tesim:#{i[3]}" + 'recto','id')['response']['docs'].map.first['id']
          # end

          folio.save
        end
      end
    end

  end

  task add_coll_order: :environment do

    require 'json'

    o = OrderedCollection.new
    o.preflabel
    o.rdftype = o.add_rdf_types
    o.coll_id = 'Abp Reg'
    o.preflabel = 'Archbishops\' Registers'
    o.save

    puts "Ordered Collection #{o.id}"

    register_order = []

    path = Rails.root + 'lib/assets/'

    f = File.read(path + 'registers/registers.json')

    JSON.parse(f)['response']['docs'].map do |r|

      puts "Processing Register #{r["dc.title"]}"

      query_string = r["dc.title"].split(':')[0]
      reg_id = SolrQuery.new.solr_query('reg_id_tesim:"' + query_string + '"', 'id')['response']['docs'].map.first['id']
      register = Register.where(id: reg_id).first
      register.ordered_collection = o
      register.save
      register_order += [register.id]

    end

    register_order.each_with_index do |reg, index|
      puts "Adding proxy for #{reg}"

      pox = Proxy.new
      pox.rdftype = pox.add_rdf_types
      pox.registers += [Register.where(id: reg).first]
      pox.ordered_collection = o
      if index == 0
        o.fst = reg
        pox.next = register_order[index + 1]
      elsif index == register_order.length - 1
        o.lst = reg
        pox.prev = register_order[index - 1]
      else
        pox.prev = register_order[index - 1]
        pox.next = register_order[index + 1]
      end
      o.proxies += [pox]
      o.save
      pox.save
    end
  end

  # Temporary code to add people ConceptScheme
  task add_people_concept_scheme: :environment do
    @scheme = ConceptScheme.new
    @scheme.title = 'people'
    @scheme.rdftype = @scheme.add_rdf_types
    @scheme.save
    puts @scheme.id
  end

  # Temporary code to add places ConceptScheme
  task add_places_concept_scheme: :environment do
    @scheme = ConceptScheme.new
    @scheme.title = 'places'
    @scheme.rdftype = @scheme.add_rdf_types
    @scheme.save
    puts @scheme.id
  end

  # we need to associate instances where there are two images with a single folio
  task register12_altimages: :environment do

    titles = ['Abp Reg 12 folio 1 recto', 'Abp Reg 12 folio 2 recto', 'Abp Reg 12 folio 118 recto']

    #find folio 1 recto, there should be two
    #take the hasFile from the second and add it to the second, then delete the second
    titles.each do |title|
      hash = Hash.new
      SolrQuery.new.solr_query('preflabel_tesim:"' + title + '*"')['response']['docs'].map do |r|
        SolrQuery.new.solr_query("hasTarget_ssim:\"#{r['id']}\"", 'id,hasTarget_ssim')['response']['docs'].map do |rr|
          hash[rr['hasTarget_ssim']] = rr['id']
        end
      end
      newfol = Folio
      puts "#{hash.length} results (if there's only one, we'll skip it)"
      hash.each_with_index do |pair, index|
        if index == 0
          puts "keep this folio: #{pair[0].first}"
          puts "keep this image: #{pair[1]}"
          newfol = Folio.where(id: pair[0]).first
        else
          puts "delete this folio: #{pair[0].first}"
          deleted_folio = Folio.where(id: pair[0].first).first

          begin
            fst = SolrQuery.new.solr_query('fst_tesim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']
          rescue
          end
          begin
            lst = SolrQuery.new.solr_query('lst_tesim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']
          rescue
          end

          if fst.nil? and lst.nil?
            # change the next and previous of adjacent proxies
            puts 'changing next and previous proxies'

            proxy_next_fol = Proxy.where(id: SolrQuery.new.solr_query('prev_tesim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']).first
            proxy_prev_fol = Proxy.where(id: SolrQuery.new.solr_query('next_tesim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']).first

            proxy_next_fol.prev = proxy_prev_fol.folios[0].id
            proxy_prev_fol.next = proxy_next_fol.folios[0].id

            puts "updated #{proxy_next_fol.id} and #{proxy_prev_fol.id}"
            proxy_next_fol.save
            proxy_prev_fol.save

          elsif fst.nil?
            # change the next and previous of adjacent proxies
            puts 'changing last and previous proxy'
            reg = Register.where(id: lst).first
            proxy_prev_fol_id = SolrQuery.new.solr_query('next_tesim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']
            reg.lst = Proxy.where(id: proxy_prev_fol_id).first.folios[0]

            proxy_prev_fol = Proxy.where(id: proxy_prev_fol_id).first
            proxy_prev_fol.next = nil

            puts "updated #{proxy_prev_fol.id} and #{reg.id}"
            reg.save
            proxy_prev_fol.save
          elsif lst.nil?
            reg = Register.where(id: SolrQuery.new.solr_query('fst_tesim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']).first
            proxy_next_fol_id = SolrQuery.new.solr_query('prev_tesim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']
            reg.fst = next_fol

            proxy_next_fol = Proxy.where(id: proxy_next_fol_id).first.folios[0]
            proxy_next_fol.prev = nil
            puts "updated #{proxy_next_fol.id} and #{reg.id}"

            reg.save
            proxy_next_fol.save
          end

          #proxy = SolrQuery.new.solr_query('proxyFor_ssim:"' + deleted_folio.id + '"')['response']['docs'].map.first['id']
          #puts "delete the proxy #{proxy.id}"
          #Proxy.where(id: proxy).first.destroy.eradicate

          puts "assoc this image: #{pair[1]} with #{newfol.id}"
          img = Image.where(id: pair[1]).first
          newfol.images += [img]
          newfol.former_id += deleted_folio.former_id
          img.folio = newfol
          newfol.save
          img.save
          puts "delete the folio #{deleted_folio.id}"
          deleted_folio.destroy.eradicate
        end
      end
    end
  end

  task coll: :environment do

    # return a hash of registers in order (id and title), for the landing page

      collection = ''
      first_register = ''
      # get the collection
      SolrQuery.new.solr_query('has_model_ssim:OrderedCollection AND coll_id_tesim:"Abp Reg"','id,fst_tesim')['response']['docs'].map.each do | result |
        collection = result['id']
        first_register = result['fst_tesim']
      end

      registers = Hash.new
      num = 0

      # get the number of registers in the collection, and the register ids and titles
      SolrQuery.new.solr_query('isPartOf_ssim:"' + collection + '"','id,preflabel_tesim,reg_id_tesim')['response'].each do | result |
        if result[0] == 'numFound'
          num = result[1]
        elsif result[0] == 'docs'
          result[1].each do | res |
            registers[res['id']] = [res['reg_id_tesim'][0],res['preflabel_tesim'][0]]
          end
        end
      end

      order = Hash.new
      next_un = ''

      # order the registers
      for i in 1..num.to_i
        case i
          when 1
            order[first_register[0]] = registers[first_register[0]]
            next_un = SolrQuery.new.solr_query('proxyFor_ssim:"' + first_register[0] + '"','next_tesim')['response']['docs'].map.first['next_tesim']
            order[next_un[0]] = registers[next_un[0]]
          when 9
            # don't process the last one
          else
            next_un = SolrQuery.new.solr_query('proxyFor_ssim:"' + next_un[0] + '"','next_tesim')['response']['docs'].map.first['next_tesim']
            order[next_un[0]] = registers[next_un[0]]
        end
      end

      order.each do | pair |
        puts pair[0]
        puts "id: #{pair[1][0]},title: #{pair[1][1]}"
      end
  end
end
