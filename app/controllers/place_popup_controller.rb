class PlacePopupController < ApplicationController

  def index

    # Should the search form or new place form be displayed?
    @type = params[:type]

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'place')
    @place_field = params[:place_field]

    # Make sure that an object exists for the new place form
    if @type == 'new_place'
      @place = Place.new
    end
  end

  def create

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a place')
    @place_field = params[:place_field]

    # Check parameters are permitted
    place_params = whitelist_place_params

    if place_params[:parent_ADM4] == ''
      @error = "Please enter a 'Parent ADM4'"
      @place = Place.new(place_params)
    else
      # Create a new place with the parameters
      # Note that a solr query is carried out to obtain the concept scheme id for 'places'
      @place = Place.new(place_params)
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @place.concept_scheme_id = id
      @place.preflabel = "#{@place.parent_ADM4}_#{@place.parent_ADM3}_#{@place.parent_ADM2}_#{@place.parent_ADM1}" # I've added ADM2 and ADM1 - is this correct?
      @place.save

      # Pass variable to view page to notify user that place has been added
      @place_name = @place.parent_ADM4

      # If the 'Submit and Add' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (post_value) and the page is closed
      if params[:commit] == 'Submit and Add'
        @commit_id = @place.id
        @commit_place_name = place_params[:parent_ADM4]
      end

      # Initialise place form again
      @place = Place.new
    end

    # View page needs to know if this is a 'new place' form or a 'search' form
    @type = 'new place'

    render 'index'
  end

  def search

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a place')
    @place_field = params[:place_field]

    @search_term = params[:search_term]

    # Get all the parent ADM4s from solr
    response = SolrQuery.new.solr_query(q='has_model_ssim:Place', fl='id, parent_ADM4_tesim, parent_ADM3_tesim, parent_ADM2_tesim, parent_ADM1_tesim', rows=1000, sort='')

    temp_hash = {}

    response['response']['docs'].map do |result|
      id = result['id']
      parent_ADM4 = result['parent_ADM4_tesim']
      parent_ADM3 = result['parent_ADM3_tesim']
      parent_ADM2 = result['parent_ADM2_tesim']
      parent_ADM1 = result['parent_ADM1_tesim']
      place_name = ''
      if parent_ADM4 != nil
        place_name = "#{parent_ADM4.join()}"
      end
      if parent_ADM3 != nil
        place_name = "#{place_name}, #{parent_ADM3.join()}"
      end
      if parent_ADM2 != nil
        place_name = "#{place_name}, #{parent_ADM2.join()}"
      end
      if parent_ADM1 != nil
        place_name = "#{place_name}, #{parent_ADM1.join()}"
      end
      if place_name != nil
        temp_hash[place_name] = id
      end
    end

    # Get all the names which match the search term and sort them
    @search_results_hash = temp_hash.select { |key, value| key.to_s.match(/#{@search_term}/i) }
    @search_results_hash = Hash[@search_results_hash.sort]

    render 'index'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_place_params
    params.require(:place).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

end