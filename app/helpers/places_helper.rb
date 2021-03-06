module PlacesHelper

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
  def get_label(is_join, place_name, parent_ADM4, parent_ADM3, parent_ADM2, parent_ADM1, feature_code=nil, url=nil)

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
        name = "#{name} (Type: #{feature_code})"
      end
    end

    if url != nil and url != ''
      if name != '' then
        name = "#{name} (<a href=\"#{url}\" target=\"_blank\">Gazetteer</a>)"
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
      @place.save
    end
  end

end
