namespace :places do

  task add_places: :environment do

    puts 'Creating the place Concept Scheme'

    begin

      @scheme = ConceptScheme.new
      @scheme.preflabel = "places"
      @scheme.rdftype = @scheme.add_rdf_types
      @scheme.save
      puts "Concept scheme for place created at #{@scheme.id}"
    rescue
      puts $!
    end
  end

  desc "TODO"
  task load_places: :environment do

    list = ['Cleveland.csv','Nottingham.csv','Diocese.csv','East Riding.csv','Richmond.csv','West Riding.csv']

    list.each do |l|
      arr = CSV.read(Rails.root + 'lib/assets/lists/places' + l)
      puts 'Processing ' + l

      arr.each do |t|
        found = false
        auth = Deep.new('subauthority')

        q = t[4]
        if q.include? '-'
          q.gsub!('-', ' ')
        end
        if t[1] == 'Cleveland'
          auth.search(q).each do |a|
            if a['featuretype'] == 'Sub-Parish' and (a['adminlevel2'].include? t[1] or a['adminlevel2'].include? 'North Riding')
              #call places helper with 'deep_' + a['id'] and deep
              check_id('deep_' + a['id'])
              # then add a note
              place_note = 'Diocese: ' + t[0]
              unless t[1] == '' or t[1].nil?
                place_note += '; Archdeaconry: ' + t[1]
              end
              unless t[2] == '' or t[2].nil?
                place_note += '; Benefice, etc.: ' + t[2]
              end
              @place.note = [place_note]
              #check we don't have it
              response = SolrQuery.new.solr_query(q='preflabel_tesim:"' + @place.preflabel + '"', fl='id', rows=1)['response']
              if response['numFound'] == 0
                begin
                  @place.save
                rescue
                  conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
                    faraday.request  :url_encoded             # form-encode POST params
                    faraday.response :logger                  # log requests to STDOUT
                    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
                  end
                  conn.delete @place.uri.to_s.gsub('http://127.0.0.1:8080/', '') + '/fcr:tombstone'
                  puts @place.uri
                  @place.save
                end
              end
              #puts 'FOUND ' + a['label']
              found = true
            end
          end

        elsif t[1] == 'Richmond'
          auth.search(q).each do |a|
            if a['featuretype'] == 'Sub-Parish' and (a['adminlevel2'].include? t[1] or a['adminlevel2'].include? 'North Riding')
              #call places helper with 'deep_' + a['id'] and deep
              check_id('deep_' + a['id'])
              # then add a note
              place_note = 'Diocese: ' + t[0]
              unless t[1] == '' or t[1].nil?
                place_note += '; Archdeaconry: ' + t[1]
              end
              unless t[2] == '' or t[2].nil?
                place_note += '; Benefice, etc.: ' + t[2]
              end
              @place.note = [place_note]
              #check we don't have it
              response = SolrQuery.new.solr_query(q='preflabel_tesim:"' + @place.preflabel + '"', fl='id', rows=1)['response']
              if response['numFound'] == 0
                begin
                  @place.save
                rescue
                  conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
                    faraday.request  :url_encoded             # form-encode POST params
                    faraday.response :logger                  # log requests to STDOUT
                    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
                  end
                  conn.delete @place.uri.to_s.gsub('http://127.0.0.1:8080/', '') + '/fcr:tombstone'
                  puts @place.uri
                  @place.save
                end
              end
              #puts 'FOUND ' + a['label']
              found = true
            end
          end

        elsif t[1] == 'York and West Riding'
          auth.search(q).each do |a|
            if a['featuretype'] == 'Sub-Parish' and (a['adminlevel2'].include? 'West Riding')
              #call places helper with 'deep_' + a['id'] and deep
              check_id('deep_' + a['id'])
              # then add a note
              place_note = 'Diocese: ' + t[0]
              unless t[1] == '' or t[1].nil?
                place_note += '; Archdeaconry: ' + t[1]
              end
              unless t[2] == '' or t[2].nil?
                place_note += '; Benefice, etc.: ' + t[2]
              end
              @place.note = [place_note]
              #check we don't have it
              response = SolrQuery.new.solr_query(q='preflabel_tesim:"' + @place.preflabel + '"', fl='id', rows=1)['response']
              if response['numFound'] == 0
                begin
                  @place.save
                rescue
                  conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
                    faraday.request  :url_encoded             # form-encode POST params
                    faraday.response :logger                  # log requests to STDOUT
                    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
                  end
                  conn.delete @place.uri.to_s.gsub('http://127.0.0.1:8080/', '') + '/fcr:tombstone'
                  puts @place.uri
                  @place.save
                end
              end
              #puts 'FOUND ' + a['label']
              found = true
            end
          end
        elsif t[1] == '' or t[1].nil?
          #skip me
        else
          auth.search(q).each do |a|
            if a['featuretype'] == 'Sub-Parish' and (a['adminlevel2'].include? t[1])
              # call places helper with 'deep_' + a['id'] and deep
              check_id('deep_' + a['id'])
              # then add a note
              place_note = 'Diocese: ' + t[0]
              unless t[1] == '' or t[1].nil?
                place_note += '; Archdeaconry: ' + t[1]
              end
              unless t[2] == '' or t[2].nil?
                place_note += '; Benefice, etc.: ' + t[2]
              end
              @place.note = [place_note]
              #check we don't have it
              response = SolrQuery.new.solr_query(q='preflabel_tesim:"' + @place.preflabel + '"', fl='id', rows=1)['response']
              if response['numFound'] == 0
                begin
                  @place.save
                rescue
                  conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
                    faraday.request  :url_encoded             # form-encode POST params
                    faraday.response :logger                  # log requests to STDOUT
                    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
                  end
                  conn.delete @place.uri.to_s.gsub('http://127.0.0.1:8080/', '') + '/fcr:tombstone'
                  puts @place.uri
                  @place.save
                end
              end
              #puts 'FOUND ' + a['label']
              found = true
            end
          end
        end
        if not found
          puts t[4]
        end
      end
    end
  end

  task load_places_cp: :environment do
    require 'faraday'

    arr = CSV.read(Rails.root + 'lib/assets/lists/places/places.csv')

    arr.each_with_index do |cp, index|
      found = false
      case cp[2]
        when '1'
          county = 'Bedfordshire'
        when '2'
          county = 'Berkshire'
        when '3'
          county = 'Buckinghamshire'
        when '4'
          county = 'Cambridgeshire'
        when '5'
          county = 'Cheshire'
        when '6'
          county = 'Cornwall'
        when '7'
          county = 'Cumberland'
        when '8'
          county = 'Derbyshire'
        when '9'
          county = 'Devon'
        when '10'
          county = 'Dorset'
        when '11'
          county = 'Durham'
        when '12'
          county = 'Essex'
        when '13'
          county = 'Gloucestershire'
        when '14'
          county = 'Hampshire'
        when '15'
          county = 'Herefordshire'
        when '16'
          county = 'Hertfordshire'
        when '17'
          county = 'Huntingdonshire'
        when '18'
          county = 'Isle Of Wight'
        when '19'
          county = 'Kent'
        when '20'
          county = 'Lancashire'
        when '21'
          county = 'Leicestershire'
        when '22'
          county = 'Lincolnshire'
        when '23'
          county = 'London'
        when '24'
          county = 'Middlesex'
        when '25'
          county = 'Norfolk'
        when '26'
          county = 'Northamptonshire'
        when '27'
          county = 'Northumberland'
        when '28'
          county = 'Nottinghamshire'
        when '29'
          county = 'Oxfordshire'
        when '30'
          county = 'Rutland'
        when '31'
          county = 'Shropshire'
        when '32'
          county = 'Somerset'
        when '33'
          county = 'Staffordshire'
        when '34'
          county = 'Suffolk'
        when '35'
          county = 'Surrey'
        when '36'
          county = 'Sussex'
        when '37'
          county = 'Warwickshire'
        when '38'
          county = 'Westmorland'
        when '39'
          county = 'Wiltshire'
        when '40'
          county = 'Worcestershire'
        when '41'
          county = 'East Riding of Yorkshire'
        when '42'
          county = 'North Riding of Yorkshire'
        when '43'
          county = 'West Riding of Yorkshire'
        when '44'
          county = 'Yorkshire'
        when '45'
          county = 'Isle Of Man'
        else
      end

      auth = Deep.new('subauthority')

      auth.search(cp[0]).each do |a|
        if a['featuretype'] == 'Sub-Parish' and (a['adminlevel2'].include? county)
          # call places helper with 'deep_' + a['id'] and deep
          check_id('deep_' + a['id'])
          response = SolrQuery.new.solr_query(q='preflabel_tesim:"' + @place.preflabel + '"', fl='id', rows=1)['response']
          if response['numFound'] == 0
            @place.feature_code += [cp[1]]
            @place.related_authority += ['http://www.hrionline.ac.uk/causepapers/xsd/parish-groups.xsd']
            begin
              @place.save
            rescue
              conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
                faraday.request  :url_encoded             # form-encode POST params
                faraday.response :logger                  # log requests to STDOUT
                faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
              end
              conn.delete @place.uri.to_s.gsub('http://127.0.0.1:8080/', '') + '/fcr:tombstone'
              puts @place.uri
              @place.save
            end
            puts "#{index.to_s}: #{@place.preflabel} (#{@place.id}) new from deep"
          else
            #need an else here
            @place = Place.find(response['docs'][0]['id'])
            @place.feature_code += [cp[1]]
            @place.related_authority += ['http://www.hrionline.ac.uk/causepapers/xsd/parish-groups.xsd']
            begin
              @place.save
            rescue
              conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
                faraday.request  :url_encoded             # form-encode POST params
                faraday.response :logger                  # log requests to STDOUT
                faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
              end
              conn.delete @place.uri.to_s.gsub('http://127.0.0.1:8080/', '') + '/fcr:tombstone'
              puts @place.uri
              @place.save
            end
            puts "#{index.to_s}: #{@place.preflabel} (#{@place.id}) updated"
          end
          #puts 'FOUND ' + a['label']
          found = true
        end
      end

      if not found
        @place = Place.new
        @place.place_name = cp[0].titleize
        @place.parent_ADM2 = county
        @place.parent_ADM1 = 'England'
        @place.feature_code = [cp[1]]
        @place.preflabel = get_label(false, @place.place_name, '', '', @place.parent_ADM2, @place.parent_ADM1)
        @place.related_authority += ['http://www.hrionline.ac.uk/causepapers/xsd/parish-groups.xsd']
        begin
          @place.save
        rescue
          conn = Faraday.new(:url => 'http://localhost:8080') do |faraday|
            faraday.request  :url_encoded             # form-encode POST params
            faraday.response :logger                  # log requests to STDOUT
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
          conn.delete @place.uri.to_s.gsub('http://127.0.0.1:8080/', '') + '/fcr:tombstone'
          puts @place.uri
          @place.save
        end
        puts "#{index.to_s}: #{@place.preflabel} (#{@place.id}) new"
      end
    end

  end

  # Check the DEEP or OS id, if it's not a local id, create a new place
  def check_id id, gaz='deep'
    if id.start_with? 'deep_'
      create_new_place(id,gaz)
    else
      id
    end
  end

  # This method is used to get the preflabel and to get the label which is displayed on the view page
  # is_join is required if the data comes from solr, i.e. when getting the data to display on the view page
  def get_label(is_join, place_name, parent_ADM4, parent_ADM3, parent_ADM2, parent_ADM1, feature_code=nil)

    name = ''

    if place_name != nil and place_name != ''
      if is_join == true then
        place_name = place_name.join
      end
      name = place_name
    end

    if parent_ADM4 != nil and parent_ADM4 != ''
      if is_join == true then
        parent_ADM4 = parent_ADM4.join
      end
      if name != '' then
        name = "#{name},"
      end
      name = "#{name} #{parent_ADM4}"
    end

    if parent_ADM3 != nil and parent_ADM3 != ''
      if is_join == true then
        parent_ADM3 = parent_ADM3.join
      end
      if name != '' then
        name = "#{name},"
      end
      name = "#{name} #{parent_ADM3}"
    end

    if parent_ADM2 != nil and parent_ADM2 != ''
      if is_join == true then
        parent_ADM2 = parent_ADM2.join
      end
      if name != '' then
        name = "#{name},"
      end
      name = "#{name} #{parent_ADM2}"
    end

    if parent_ADM1 != nil and parent_ADM1 != ''
      if is_join == true then
        parent_ADM1 = parent_ADM1.join
      end
      if name != '' then
        name = "#{name},"
      end
      name = "#{name} #{parent_ADM1}"
    end

    if feature_code != nil and feature_code != ''
      if name != '' then
        name = "#{name} (Feature Type: #{feature_code})"
      end
    end

    return name
  end

  private

  def create_new_place id,gaz
    response = SolrQuery.new.solr_query(q='same_as_tesim:"' + "http://unlock.edina.ac.uk/ws/search?name=#{id.gsub('deep_', '')}&format=json" + '"', fl='id', rows=1)['response']
    if response['numFound'] == 0
      @place = Place.new
      if gaz == 'deep'
        auth = Deep.new('subauthority')
        build_place(auth,id)
        if @place.id.nil?
          auth = OrdnanceSurvey.new('subauthority')
          build_place(auth,id,'os')
        end
      elsif gaz == 'os'
        auth = OrdnanceSurvey.new('subauthority')
        build_place(auth,id,'os')
      end
    else
      @place = Place.find(response['docs'][0]['id'])
    end
    @place.id
  end

  # Create a new place with data from DEEP / OS
  def build_place auth,id,gaz='deep'
    auth.search_by_id(id.gsub('deep_','')).each do |result|
      @place.rdftype = @place.add_rdf_types
      if gaz == 'deep'
        @place.same_as = ["http://unlock.edina.ac.uk/ws/search?name=#{id.gsub('deep_','')}&gazetteer=deep&format=json"]
      else
        @place.same_as = ["http://unlock.edina.ac.uk/ws/search?name=#{id.gsub('deep_','')}&format=json"]
      end
      @place.place_name = result['name']
      @place.parent_ADM4 = result['adminlevel4']
      @place.parent_ADM3 = result['adminlevel3']
      @place.parent_ADM2 = result['adminlevel2']
      @place.parent_ADM1 = result['adminlevel1']
      @place.feature_code = [result['featuretype']]
      unless result['uricdda'].nil?
        @place.related_authority << [result['uricdda']]
      end
      @place.preflabel = get_label(false, @place.place_name, @place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)
      # Use a solr query to obtain the concept scheme id for 'places'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      @place.concept_scheme_id = response['response']['docs'][0]['id']
      #@place.save
    end
  end

end
