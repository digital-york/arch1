class PeopleController < ApplicationController

  before_filter :session_timed_out_small

  #INDEX
  def index

    session[:person_list_type] = 'person'

    if params[:start] == 'true' then session[:person_search_term] = '' end

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'person')
    if params[:person_field] != nil
      session[:person_field] = params[:person_field]
    end

    # Set the session search_term variable if it is passed as a parameter
    if params[:search_term] != nil then session[:person_search_term] = params[:search_term] end

    @search_array = []

    # Get Concepts for the Person ConceptScheme and filter according to search_term
    SolrQuery.new.solr_query(q='has_model_ssim:Person', fl='id, family_tesim, pre_title_tesim, given_name_tesim, post_title_tesim, epithet_tesim', rows=1000, sort='id asc')['response']['docs'].map.each do |result|

      id = result['id']
      family = result['family_tesim'].join
      pre_title = result['pre_title_tesim']
      given_name = result['given_name_tesim']
      post_title = result['post_title_tesim']
      epithet = result['epithet_tesim']

      tt = []
      name = family

      if pre_title != nil then
        name = "#{name}, #{pre_title.join()}"
      end
      if given_name != nil then
        name = "#{name}, #{given_name.join()}"
      end
      if post_title != nil then
        name = "#{name}, #{post_title.join()}"
      end
      if epithet != nil then
        name = "#{name}, #{epithet.join()}"
      end

      if name.match(/#{session[:person_search_term]}/i)
        tt << id
        tt << name
        @search_array << tt
      end
    end

    # Sort the array by family
    @search_array = @search_array.sort_by { |k| k[1] }

  end

  # SHOW
  def show
  end

  # NEW
  def new
    @person = Person.new
  end

  # EDIT
  def edit
    @person = Person.find(params[:id])
  end

  # CREATE
  def create

    # Check parameters are permitted
    person_params = whitelist_person_params

    # Remove any empty fields
    remove_person_popup_empty_fields(person_params)

    @error = ''

    if person_params[:family] == ''
      @error = "Please enter a 'Family'"
    end

    # Check that same_as is a URL
    @error = check_url(person_params[:same_as], @error, "Same As")

    # Check that related_authority is a URL
    @error = check_url(person_params[:related_authority], @error, "Related Authority")

    if @error != ''
      @person = Person.new(person_params)
    else

      # Create a new person with the parameters
      @person = Person.new(person_params)

      # Use a solr query to obtain the concept scheme id for 'people'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"people"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @person.concept_scheme_id = id

      # Get preflabel
      @person.preflabel = get_preflabel(@person.family, @person.pre_title, @person.given_name, @person.post_title, @person.epithet)

      @person.save

      # Pass variable to view page to notify user that person has been added.
      @person_name = @person.family

      # If the 'Submit and Close' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (i.e. post_value()) and the page is closed
      if params[:commit] == 'Submit and Close'
        @commit_id = @person.id
        @commit_person_name = person_params[:family]
      end

      # Initialise person form again
      @person = Person.new
    end

    render 'new'
  end

  # UPDATE
  def update

    # Check parameters are permitted
    person_params = whitelist_person_params

    # Remove any empty fields
    remove_person_popup_empty_fields(person_params)

    @error = ''

    if person_params[:family] == ''
      @error = "Please enter a 'Family'"
    end

    # Check that same_as is a URL
    @error = check_url(person_params[:same_as], @error, "Same As")

    # Check that related_authority is a URL
    @error = check_url(person_params[:related_authority], @error, "Related Authority")

    # Get a person object using the id and populate it with the person parameters
    @person = Person.find(params[:id])
    @person.attributes = person_params

    # Use a solr query to obtain the concept scheme id for 'people'
    response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"people"', fl='id', rows=1, sort='')
    id = response['response']['docs'][0]['id']
    @person.concept_scheme_id = id

    # Get preflabel
    @person.preflabel = get_preflabel(@person.family, @person.pre_title, @person.given_name, @person.post_title, @person.epithet)

    @person.save

    # Pass variable to view page to notify user that person has been updated.
    @person_name = @person.family

    render 'edit'

  end

  # DESTROY
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    redirect_to :controller => 'people', :action => 'index'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_person_params
    params.require(:person).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

  # Get the preflabel from the solr parameters (separated by an underscore)
  def get_preflabel(family, pre_title, given_name, post_title, epithet)

    preflabel = family

    preflabel2 = ''

    if pre_title != '' then
      preflabel2 = "#{pre_title}"
    end
    if given_name != '' then
      if preflabel2 != '' then preflabel2 = "#{preflabel2}, " end
      preflabel2 = "#{preflabel2}#{given_name}"
    end
    if post_title != '' then
      if preflabel2 != '' then preflabel2 = "#{preflabel2}, " end
      preflabel2 = "#{preflabel2}#{post_title}"
    end
    if epithet != '' then
      if preflabel2 != '' then preflabel2 = "#{preflabel2}, " end
      preflabel2 = "#{preflabel2}#{epithet}"
    end

    # Put brackets around preflabel2 if it exists
    if preflabel2 != '' then preflabel = "#{preflabel} (#{preflabel2})" end

    return preflabel
  end

end