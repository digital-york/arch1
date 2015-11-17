module PlacesHelper

  def check_id id
    if id.start_with? 'deep_'
      create_new_deep_place(id)
      @place.id
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

  def create_new_deep_place id
    @place = Place.new
    Deep.new('subauthority').search(id.gsub('deep_','')).each do |result|
      @place.rdftype = @place.add_rdf_types
      @place.same_as = ["http://unlock.edina.ac.uk/ws/search?name=#{id.gsub('deep_','')}&gazetteer=deep&format=json"]
      @place.place_name = result['name']
      @place.parent_ADM4 = result['adminlevel4']
      @place.parent_ADM3 = result['adminlevel3']
      @place.parent_ADM2 = result['adminlevel2']
      @place.parent_ADM1 = result['adminlevel1']
      @place.feature_code = [result['featuretype']]
      @place.preflabel = get_label(false, @place.place_name, @place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)
      # Use a solr query to obtain the concept scheme id for 'places'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      @place.concept_scheme_id = response['response']['docs'][0]['id']
      @place.save
    end
  end

end
