class PersonPopupController < ApplicationController

  def index

    @type = params[:type]
    @person_field = params[:person_field]

    if @type == nil || @type == ''
    elsif @type == 'new_person'
      @person = Person.new
    end

  end

  def new
  end

  def create

    @person_field = params[:person_field]

    # Check parameters are valid
    person_params = whitelist_person_params

    #Create the new person with the parameters
    @person = Person.new(person_params)
    response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND title_tesim:people', fl='id', rows=1, sort='')
    id = response['response']['docs'][0]['id']
    @person.concept_scheme_id = id
    @person.save

    # Pass variable to view page to notify user that perosn has been added
    @person_name = @person.family

    # Initialise person form again
    @person = Person.new

    # View page needs to know if this is a 'new person' form or a 'search' form
    @type = 'new person'

    render 'index'
  end

  def search

    @person_field = params[:person_field]

    @search_term = params[:search_term]

    response = SolrQuery.new.solr_query(q='has_model_ssim:Person', fl='id, family_tesim', rows=1000, sort='')

    temp_hash = {}

    response['response']['docs'].map do |result|
      id = result['id']
      family_name = result['family_tesim']
      if family_name != nil
        temp_hash[family_name.join()] = id
      end
    end

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