class PlacesController < ApplicationController

  before_filter :session_timed_out_small

  #INDEX
  def index

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'place')
    @place_field = params[:place_field]

    # Set the search_term variable if it is passed as a parameter
    @search_term = ''
    if params[:search_term_index] != nil
      @search_term = params[:search_term_index]
    else
      @search_term = params[:search_term]
    end

    @search_array = []

    # Get Concepts for the Place ConceptScheme and filter according to search_term
    SolrQuery.new.solr_query(q='has_model_ssim:Place', fl='id, place_name_tesim, parent_ADM4_tesim, parent_ADM3_tesim, parent_ADM2_tesim, parent_ADM1_tesim', rows=1000, sort='id asc')['response']['docs'].map.each do |result|

      id = result['id']
      place_name = result['place_name_tesim']
      parent_ADM4 = result['parent_ADM4_tesim']
      parent_ADM3 = result['parent_ADM3_tesim']
      parent_ADM2 = result['parent_ADM2_tesim']
      parent_ADM1 = result['parent_ADM1_tesim']

      tt = []
      name = get_label(true, place_name, parent_ADM4, parent_ADM3, parent_ADM2, parent_ADM1)

      if name.match(/#{@search_term}/i)
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
    @search_term = params[:search_term]
    @place_field = params[:place_field]
  end

  # EDIT
  def edit
    @place = Place.find(params[:id])
    @search_term = params[:search_term]
    @place_field = params[:place_field]
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
      @search_term = params[:search_term]
      @place_field = params[:place_field]
      render 'new'
    else

      # Use a solr query to obtain the concept scheme id for 'places'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @place.concept_scheme_id = id

      # Get preflabel, rdftype and save
      @place.preflabel = get_label(false, @place.place_name, @place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)
      @place.rdftype << @place.add_rdf_types
      @place.save

      # If the 'Submit and Close' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (i.e. post_value()) and the page is closed
      if params[:commit] == 'Submit and Close'
        @commit_id = @place.id
        @commit_place_name = place_params[:place_name]
      end

      redirect_to :controller => 'places', :action => 'index', :search_term => params[:search_term], :place_field => params[:place_field]
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
      @search_term = params[:search_term]
      @place_field = params[:place_field]
      render 'edit'
    else
      @place.preflabel = get_label(false, @place.place_name, @place.parent_ADM4, @place.parent_ADM3, @place.parent_ADM2, @place.parent_ADM1)
      @place.save
      redirect_to :controller => 'places', :action => 'index', :search_term => params[:search_term], :place_field => params[:place_field]
    end
  end

  # DESTROY
  def destroy

    @place = Place.find(params[:id])

    # Check if the place is present in any of the entries
    # If so, direct the user to a page with the entry locations so that they can remove them
    existing_location_list = get_existing_location_list('place_same_as', @place.id)

    if existing_location_list.size > 0
      render 'place_exists_list', :locals => { :@place_name => @place.place_name, :id => @place.id, :@existing_location_list => existing_location_list, :@go_back_id =>  params[:go_back_id], :@search_term => params[:search_term], :@place_field => params[:place_field] }
    else
      @place.destroy
      redirect_to :controller => 'places', :action => 'index', :search_term => params[:search_term], :place_field => params[:place_field]
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_place_params
    params.require(:place).permit(:place_name, :parent_ADM4, :parent_ADM3, :parent_ADM2, :parent_ADM1, :parent_country, :feature_code => [], :same_as => [], :related_authority => [], :altlabel => [])  # Note - arrays need to go at the end or an error occurs!
  end

  # This method is used to get the preflabel and to get the label which is displayed on the view page
  # is_join is required if the data comes from solr, i.e. when getting the data to display on the view page
  def get_label(is_join, place_name, parent_ADM4, parent_ADM3, parent_ADM2, parent_ADM1)

    name = ''

    if place_name != nil and place_name != ''
      if is_join == true then place_name = place_name.join end
      name = place_name
    end

    if parent_ADM4 != nil and parent_ADM4 != ''
      if is_join == true then parent_ADM4 = parent_ADM4.join end
      if name != '' then name = "#{name}," end
      name = "#{name} #{parent_ADM4}"
    end

    if parent_ADM3 != nil and parent_ADM3 != ''
      if is_join == true then parent_ADM3 = parent_ADM3.join end
      if name != '' then name = "#{name}," end
      name = "#{name} #{parent_ADM3}"
    end

    if parent_ADM2 != nil and parent_ADM2 != ''
      if is_join == true then parent_ADM2 = parent_ADM2.join end
      if name != '' then name = "#{name}," end
      name = "#{name} #{parent_ADM2}"
    end

    if parent_ADM1 != nil and parent_ADM1 != ''
      if is_join == true then parent_ADM1 = parent_ADM1.join end
      if name != '' then name = "#{name}," end
      name = "#{name} #{parent_ADM1}"
    end

    return name
  end

end