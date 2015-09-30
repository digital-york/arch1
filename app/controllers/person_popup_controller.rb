class PersonPopupController < ApplicationController

  def index

    # Should the search form or new person form be displayed?
    @type = params[:type]

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'person')
    @person_field = params[:person_field]

    # Make sure that an object exists for the new person form
    if @type == 'new_person'
      @person = Person.new
    end
  end

  def create

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a person')
    @person_field = params[:person_field]


    # Check parameters are permitted
    person_params = whitelist_person_params

    # Remove any empty fields
    remove_person_popup_empty_fields(person_params)

    @error = ''

    if person_params[:family] == ''
      @error = "Please enter a family name"
    end

    same_as = person_params[:same_as]

    if same_as != nil
      same_as = same_as.join()
      if same_as !~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
        if @error != ''
          @error = @error + "<br/>"
        end
        @error = @error + "Please enter a valid  URL for 'Same As'"
      end
    end

    if @error != ''
      @person = Person.new(person_params)
    else

      # Create a new person with the parameters
      @person = Person.new(person_params)

      # Use a solr query to obtain the concept scheme id for 'people'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:people', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @person.concept_scheme_id = id

      @person.rules = 'NCARules'

      # Add the appropriate preflabel values separated by an underscore
      @person.preflabel = "#{@person.family}"
      if @person.pre_title != '' then @person.preflabel = "#{@person.preflabel}_#{@person.pre_title}" end
      if @person.given_name != '' then @person.preflabel = "#{@person.preflabel}_#{@person.given_name}" end
      if @person.post_title != '' then @person.preflabel = "#{@person.preflabel}_#{@person.post_title}" end
      if @person.epithet != '' then @person.preflabel = "#{@person.preflabel}_#{@person.epithet}" end

      @person.save

      # Pass variable to view page to notify user that person has been added
      @person_name = @person.family

      # If the 'Submit and Add' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (place_value) and the page is closed
      if params[:commit] == 'Submit and Add'
        @commit_id = @person.id
        @commit_person_name = person_params[:family]
      end

      # Initialise person form again
      @person = Person.new
    end

    # View page needs to know if this is a 'new person' form or a 'search' form
    @type = 'new person'

    render 'index'
  end

  def search

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a person')
    @person_field = params[:person_field]

    @search_term = params[:search_term]

    # Get all the family names from solr
    response = SolrQuery.new.solr_query(q='has_model_ssim:Person', fl='id, family_tesim', rows=1000, sort='')

    temp_hash = {}

    response['response']['docs'].map do |result|
      id = result['id']
      family_name = result['family_tesim']
      if family_name != nil
        temp_hash[family_name.join()] = id
      end
    end

    # Get all the names which match the search term and sort them
    @search_results_hash = temp_hash.select { |key, value| key.to_s.match(/#{@search_term}/i) }
    @search_results_hash = Hash[@search_results_hash.sort]

    render 'index'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_person_params
    params.require(:person).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

end