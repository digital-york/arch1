class PeopleController < ApplicationController

  before_filter :session_timed_out_small

  # INDEX
  def index

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'person')
    if params[:person_field] != nil
      session[:person_field] = params[:person_field]
    end

    # If the popup has just been opened, set the session variable to ''
    if params[:start] == 'true'

      session[:person_search_term] = nil

    # Else do a search using params[:search_term] or session[person_search_term]
    else

      # Update the session variable with the new search term
      if params[:search_term] != nil then session[:person_search_term] = params[:search_term] end

      if session[:person_search_term] != nil

        # Get the necessary info from solr
        response = SolrQuery.new.solr_query(q='has_model_ssim:Person', fl='id, family_tesim, pre_title_tesim, given_name_tesim, post_title_tesim, epithet_tesim', rows=1000, sort='')

        temp_hash = {}

        response['response']['docs'].map do |result|

          id = result['id']
          family = result['family_tesim']
          pre_title = result['pre_title_tesim']
          given_name = result['given_name_tesim']
          post_title = result['post_title_tesim']
          epithet = result['epithet_tesim']

          person_name = ''

          if family != nil then
            person_name = "#{family.join()}"
          end
          if pre_title != nil then
            person_name = "#{person_name}, #{pre_title.join()}"
          end
          if given_name != nil then
            person_name = "#{person_name}, #{given_name.join()}"
          end
          if post_title != nil then
            person_name = "#{person_name}, #{post_title.join()}"
          end
          if epithet != nil then
            person_name = "#{person_name}, #{epithet.join()}"
          end
          if person_name != nil then
            temp_hash[person_name] = id
          end
        end

        # Get all the names which match the search term and sort them
        @search_hash = temp_hash.select { |key, value| key.to_s.match(/#{session[:person_search_term]}/i) }
        @search_hash = Hash[@search_hash.sort]
      end

    end
  end

  # SHOW
  def show
    @person = Person.find(params[:id])
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

    if @error != ''
      render 'edit'
    else

      # Use a solr query to obtain the concept scheme id for 'people'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"people"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @person.concept_scheme_id = id

      # Get preflabel
      @person.preflabel = get_preflabel(@person.family, @person.pre_title, @person.given_name, @person.post_title, @person.epithet)

      @person.save

      # Pass variable to view page to notify user that person has been updated.
      @person_name = @person.family

      redirect_to :controller => 'people', :action => 'show', :id => @person.id
    end

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