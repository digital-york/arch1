class PlacesController < ApplicationController

  # INDEX
  def index
    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'place')
    if params[:place_field] != nil
      session[:place_field] = params[:place_field]
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

    same_as = place_params[:same_as]

    if same_as != nil
      same_as = same_as.join()
      if same_as !~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
        if @error != ''
          @error = @error + "<br/>"
        end
        @error = @error + "Please enter a valid  URL for 'Same As'"
      end
    end

    place_authority = place_params[:related_authority]

    if place_authority != nil
      place_authority = place_authority.join()
      if place_authority !~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
        if @error != ''
          @error = @error + "<br/>"
        end
        @error = @error + "Please enter a valid  URL for 'Related Authority'"
      end
    end

    if @error != ''
      @place = Place.new(place_params)
    else

      # Create a new place with the parameters
      @place = Place.new(place_params)

      # Use a solr query to obtain the concept scheme id for 'places'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"places"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @place.concept_scheme_id = id

      # Add the parent ADM values to preflabel separated by an underscore
      @place.preflabel = "#{@place.parent_ADM4}"
      if @place.parent_ADM3 != '' then @place.preflabel = "#{@place.preflabel}_#{@place.parent_ADM3}" end
      if @place.parent_ADM2 != '' then @place.preflabel = "#{@place.preflabel}_#{@place.parent_ADM2}" end
      if @place.parent_ADM1 != '' then @place.preflabel = "#{@place.preflabel}_#{@place.parent_ADM1}" end

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
puts "UPDATE"
    # Check parameters are permitted
    place_params = whitelist_place_params

    # Remove any empty fields
    remove_place_popup_empty_fields(place_params)

    @error = ''

    if place_params[:parent_ADM4] == ''
      @error = "Please enter a 'Parent ADM4'"
    end

    same_as = place_params[:same_as]

    if same_as != nil
      same_as = same_as.join()
      if same_as !~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
        if @error != ''
          @error = @error + "<br/>"
        end
        @error = @error + "Please enter a valid  URL for 'Same As'"
      end
    end

    place_authority = place_params[:related_authority]

    if place_authority != nil
      place_authority = place_authority.join()
      if place_authority !~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
        if @error != ''
          @error = @error + "<br/>"
        end
        @error = @error + "Please enter a valid  URL for 'Related Authority'"
      end
    end

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

      # Add the parent ADM values to preflabel separated by an underscore
      @place.preflabel = "#{@place.parent_ADM4}"
      if @place.parent_ADM3 != '' then @place.preflabel = "#{@place.preflabel}_#{@place.parent_ADM3}" end
      if @place.parent_ADM2 != '' then @place.preflabel = "#{@place.preflabel}_#{@place.parent_ADM2}" end
      if @place.parent_ADM1 != '' then @place.preflabel = "#{@place.preflabel}_#{@place.parent_ADM1}" end

      @place.save

      # Pass variable to view page to notify user that place has been updated.
      @place_name = @place.parent_ADM4

      redirect_to :controller => 'places', :action => 'show', :id => @place.id
    end

  end

  # DESTOY
  def destroy
    @place = Place.find(params[:id])
    @place.destroy
    redirect_to :controller => 'places', :action => 'search', :search_term => session[:place_search_term]
  end

  # SEARCH
  def search

if @search_term == nil
@search_term = ''
end

    @search_term = params[:search_term]

    session[:place_search_term] = @search_term
#puts "st = #{session[:place_search_term]}"
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