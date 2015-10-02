class PlacesController < ApplicationController

  before_filter :session_timed_out_small

  # INDEX
  def index

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'place')
    if params[:place_field] != nil
      session[:place_field] = params[:place_field]
    end

    # If the popup has just been opened, set the session variable to ''
    if params[:start] == 'true'

      session[:place_search_term] = ''

    # Else do a search using the params[:search_term] or session[place_search_term]
    else

      # Update the session variable with the new search term
      if params[:search_term] != nil
        session[:place_search_term] = params[:search_term]
      end

      # Get all the parent ADMs from solr
      response = SolrQuery.new.solr_query(q='has_model_ssim:Place', fl='id, parent_ADM4_tesim, parent_ADM3_tesim, parent_ADM2_tesim, parent_ADM1_tesim', rows=1000, sort='')

      temp_hash = {}

      response['response']['docs'].map do |result|
        id = result['id']
        parent_ADM4 = result['parent_ADM4_tesim']
        parent_ADM3 = result['parent_ADM3_tesim']
        parent_ADM2 = result['parent_ADM2_tesim']
        parent_ADM1 = result['parent_ADM1_tesim']
        place_name = ''
        if parent_ADM4 != nil then place_name = "#{parent_ADM4.join()}" end
        if parent_ADM3 != nil then place_name = "#{place_name}, #{parent_ADM3.join()}" end
        if parent_ADM2 != nil then place_name = "#{place_name}, #{parent_ADM2.join()}" end
        if parent_ADM1 != nil then place_name = "#{place_name}, #{parent_ADM1.join()}" end
        if place_name != nil then temp_hash[place_name] = id end
      end

      # Get all the names which match the search term and sort them
      @search_hash = temp_hash.select { |key, value| key.to_s.match(/#{session[:place_search_term]}/i) }
      @search_hash = Hash[@search_hash.sort]

    end
  end

  # SHOW
  def show
    @place = Place.find(params[:id])
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

    if place_params[:parent_ADM4] == ''
      @error = "Please enter a 'Parent ADM4'"
    end

    # Check that same_as is a URL
    @error = check_url(place_params[:same_as], @error, "Same As")

    # Check that related_authority is a URL
    @error = check_url(place_params[:related_authority], @error, "Related Authority")

    if @error != ''
      @place = Place.new(place_params)
    else

      # Create a new place with the parameters
      @place = Place.new(place_params)

      # Use a solr query to obtain the concept scheme id for 'places'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @place.concept_scheme_id = id

      # Get preflabel
      @place.preflabel = get_preflabel(@place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)

      @place.save

      # Pass variable to view page to notify user that place has been added.
      @place_name = @place.parent_ADM4

      # If the 'Submit and Close' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (i.e. post_value()) and the page is closed
      if params[:commit] == 'Submit and Close'
        @commit_id = @place.id
        @commit_place_name = place_params[:parent_ADM4]
      end

      # Initialise place form again
      @place = Place.new
    end

    render 'new'
  end

  # UPDATE
  def update

    # Check parameters are permitted
    place_params = whitelist_place_params

    # Remove any empty fields
    remove_place_popup_empty_fields(place_params)

    @error = ''

    if place_params[:parent_ADM4] == ''
      @error = "Please enter a 'Parent ADM4'"
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
      @place.preflabel = get_preflabel(@place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)

      @place.save

      # Pass variable to view page to notify user that place has been updated.
      @place_name = @place.parent_ADM4

      redirect_to :controller => 'places', :action => 'show', :id => @place.id
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
  def get_preflabel(parent_ADM4, parent_ADM3, parent_ADM2, parent_ADM1)
    preflabel = parent_ADM4
    if parent_ADM3 != '' then preflabel = "#{preflabel}_#{parent_ADM3}" end
    if parent_ADM2 != '' then preflabel = "#{preflabel}_#{parent_ADM2}" end
    if parent_ADM1 != '' then preflabel = "#{preflabel}_#{parent_ADM1}" end
    return preflabel
  end

end