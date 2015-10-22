class PlacesController < ApplicationController

  before_filter :session_timed_out_small

  #INDEX
  def index

    if params[:start] == 'true' then session[:place_search_term] = '' end

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'place')
    if params[:place_field] != nil
      session[:place_field] = params[:place_field]
    end

    # Set the session search_term variable if it is passed as a parameter
    if params[:search_term] != nil then session[:place_search_term] = params[:search_term] end

    @search_array = []

    # Get Concepts for the Place ConceptScheme and filter according to search_term
    SolrQuery.new.solr_query(q='has_model_ssim:Place', fl='id, place_name_tesim, parent_ADM4_tesim, parent_ADM3_tesim, parent_ADM2_tesim, parent_ADM1_tesim', rows=1000, sort='id asc')['response']['docs'].map.each do |result|

      id = result['id']
      place_name = result['place_name_tesim'].join
      parent_ADM4 = result['parent_ADM4_tesim']
      parent_ADM3 = result['parent_ADM3_tesim']
      parent_ADM2 = result['parent_ADM2_tesim']
      parent_ADM1 = result['parent_ADM1_tesim']

      tt = []
      name = place_name

      if parent_ADM4 != nil then
        name = "#{name}, #{parent_ADM4.join()}"
      end
      if parent_ADM3 != nil then
        name = "#{name}, #{parent_ADM3.join()}"
      end
      if parent_ADM2 != nil then
        name = "#{name}, #{parent_ADM2.join()}"
      end
      if parent_ADM1 != nil then
        name = "#{name}, #{parent_ADM1.join()}"
      end

      if name.match(/#{session[:place_search_term]}/i)
        tt << id
        tt << name
        @search_array << tt
      end
    end

    # Sort the array by place_name
    @search_array = @search_array.sort_by { |k| k[1] }

  end

  # SHOW
  def show
  end

  # NEW
  def new
    @place = Place.new
  end

  # EDIT
  def edit
    @place = Place.find(params[:id])
  end

  # CREATE
  def create

    # Check parameters are permitted
    place_params = whitelist_place_params

    # Remove any empty fields
    remove_place_popup_empty_fields(place_params)

    @error = ''

    if place_params[:place_name] == ''
      @error = "Please enter a 'Place Name'"
    end

    # Check that same_as is a URL
    @error = check_url(place_params[:same_as], @error, "Same As")

    # Check that related_authority is a URL
    @error = check_url(place_params[:related_authority], @error, "Related Authority")

    @place = Place.new(place_params)

    if @error != ''
      render 'new'
    else

      # Use a solr query to obtain the concept scheme id for 'places'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @place.concept_scheme_id = id

      # Get preflabel
      @place.preflabel = get_preflabel(@place.place_name, @place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)

      @place.save

      # If the 'Submit and Close' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (i.e. post_value()) and the page is closed
      if params[:commit] == 'Submit and Close'
        @commit_id = @place.id
        @commit_place_name = place_params[:place_name]
      end

      redirect_to :controller => 'places', :action => 'index'
    end
  end

  # UPDATE
  def update

    # Check parameters are permitted
    place_params = whitelist_place_params

    # Remove any empty fields
    remove_place_popup_empty_fields(place_params)

    @error = ''

    if place_params[:place_name] == ''
      @error = "Please enter a 'Place Name'"
    end

    # Check that same_as is a URL
    @error = check_url(place_params[:same_as], @error, "Same As")

    # Check that related_authority is a URL
    @error = check_url(place_params[:related_authority], @error, "Related Authority")

    # Get a place object using the id and populate it with the place parameters
    @place = Place.find(params[:id])
    @place.attributes = place_params

    if @error != ''
      render 'edit'
    else

      # Use a solr query to obtain the concept scheme id for 'places'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @place.concept_scheme_id = id

      # Get preflabel
      @place.preflabel = get_preflabel(@place.place_name, @place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)

      @place.save

      redirect_to :controller => 'places', :action => 'index'
    end
  end

  # DESTROY
  def destroy
    @place = Place.find(params[:id])
    @place.destroy
    redirect_to :controller => 'places', :action => 'index'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_place_params
    params.require(:place).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

  # Get the preflabel from the solr parameters (separated by an underscore)
  def get_preflabel(place_name, parent_ADM4, parent_ADM3, parent_ADM2, parent_ADM1)

    preflabel = place_name

    preflabel2 = ''

    if parent_ADM4 != ''
      preflabel2 = "#{parent_ADM4}"
    end
    if parent_ADM3 != ''
      if preflabel2 != '' then preflabel2 = "#{preflabel2}, " end
      preflabel2 = "#{preflabel2}#{parent_ADM3}"
    end
    if parent_ADM2 != ''
      if preflabel2 != '' then preflabel2 = "#{preflabel2}, " end
      preflabel2 = "#{preflabel2}#{parent_ADM2}"
    end
    if parent_ADM1 != ''
      if preflabel2 != '' then preflabel2 = "#{preflabel2}, " end
      preflabel2 = "#{preflabel2}#{parent_ADM1}"
    end

    # Put brackets around preflabel2 if it exists
    if preflabel2 != '' then preflabel = "#{preflabel} (#{preflabel2})" end

    return preflabel
  end

end