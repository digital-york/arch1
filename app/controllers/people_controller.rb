# frozen_string_literal: true

class PeopleController < ApplicationController
  before_action :session_timed_out_small

  # INDEX
  def index
    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'person')
    @person_field = params[:person_field]

    # Set the search_term variable if it is passed as a parameter
    @search_term = ''
    @search_term = if !params[:search_term_index].nil?
                     params[:search_term_index]
                   else
                     params[:search_term]
                   end

    @search_array = []

    # Get Concepts for the Person ConceptScheme and filter according to search_term
    num = SolrQuery.new.solr_query(q = 'has_model_ssim:Person', fl = 'id', rows = 0)['response']['numFound']
    SolrQuery.new.solr_query(q = 'has_model_ssim:Person', fl = 'id, preflabel_tesim', rows = num, sort = 'preflabel_si asc')['response']['docs'].map.each do |result|
      id = result['id']
      preflabel = result['preflabel_tesim'].join

      tt = []

      next unless preflabel.match(/#{@search_term}/i)

      tt << id
      tt << preflabel
      @search_array << tt
    end

    # Sort the array by family
    @search_array = @search_array.sort_by { |k| k[1] }
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # SHOW
  def show; end

  # NEW
  def new
    @person = Person.new
    @search_term = params[:search_term]
    @person_field = params[:person_field]
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # EDIT
  def edit
    @person = Person.find(params[:id])
    @search_term = params[:search_term]
    @person_field = params[:person_field]
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # CREATE
  def create
    # Check parameters are permitted
    person_params = whitelist_person_params

    # Remove any empty fields
    remove_person_popup_empty_fields(person_params)

    @error = ''

    if (person_params[:family] == '') && (person_params[:given_name] == '')
      @error = "Please enter a 'Family Name or Given Name'"
    end

    # Check that same_as is a URL
    @error = check_url(person_params[:same_as], @error, 'Same As')

    # Disable this check
    # Check that related_authority is a URL
    # @error = check_url(person_params[:related_authority], @error, "Related Authority")

    @person = Person.new(person_params)

    if @error != ''
      @search_term = params[:search_term]
      @person_field = params[:person_field]
      render 'new'
    else

      # Use a solr query to obtain the concept scheme id for 'people'
      response = SolrQuery.new.solr_query(q = 'has_model_ssim:ConceptScheme AND preflabel_tesim:"people"', fl = 'id', rows = 1, sort = '')
      id = response['response']['docs'][0]['id']
      @person.concept_scheme_id = id

      # Get preflabel, rdftype and save
      @person.preflabel = get_preflabel(@person.family, @person.pre_title, @person.given_name, @person.dates, @person.post_title, @person.epithet)
      @person.rdftype << @person.add_rdf_types
      @person.save

      # If the 'Submit and Close' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (i.e. post_value()) and the page is closed
      if params[:commit] == 'Submit and Close'
        @commit_id = @person.id
        @commit_person_name = person_params[:family]
      end

      redirect_to controller: 'people', action: 'index', search_term: params[:search_term], person_field: params[:person_field]
    end
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # UPDATE
  def update
    # Check parameters are permitted
    person_params = whitelist_person_params

    # Remove any empty fields
    remove_person_popup_empty_fields(person_params)

    @error = ''

    if (person_params[:family] == '') && (person_params[:given_name] == '')
      @error = "Please enter a 'Family Name or Given Name'"
    end

    # Check that same_as is a URL
    @error = check_url(person_params[:same_as], @error, 'Same As')

    # Disable this check
    # Check that related_authority is a URL
    # @error = check_url(person_params[:related_authority], @error, "Related Authority")

    # Get a person object using the id and populate it with the person parameters
    @person = Person.find(params[:id])
    @person.attributes = person_params

    if @error != ''
      @search_term = params[:search_term]
      @person_field = params[:person_field]
      render 'edit'
    else
      @person.preflabel = get_preflabel(@person.family, @person.pre_title, @person.given_name, @person.dates, @person.post_title, @person.epithet)
      @person.save
      # solr update any related objects
      update_related('person', @person.id)
      redirect_to controller: 'people', action: 'index', search_term: params[:search_term], person_field: params[:person_field]
    end
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # DESTROY
  def destroy
    @person = Person.find(params[:id])

    # Check if the person is present in any of the entries
    # If so, direct the user to a page with the entry locations so that they can remove them
    existing_location_list = get_existing_location_list('person_same_as', @person.id)

    if !existing_location_list.empty?
      render 'person_exists_list', locals: { :@person_name => @person.family, :id => @person.id, :@existing_location_list => existing_location_list, :@go_back_id => params[:go_back_id], :@search_term => params[:search_term], :@person_field => params[:person_field] }
    else
      @person.destroy
      redirect_to controller: 'people', action: 'index', search_term: params[:search_term], person_field: params[:person_field]
    end
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_person_params
    params.require(:person).permit(:family, :pre_title, :given_name, :dates, :post_title, :epithet, :dates_of_office, same_as: [], related_authority: [], altlabel: [], note: []) # Note - arrays need to go at the end or an error occurs!
  end

  # This method is used to get the preflabel and to get the label which is displayed on the view page
  # is_join is required if the data comes from solr, i.e. when getting the data to display on the view page
  def get_preflabel(family, pre_title, given_name, dates, post_title, epithet)
    name = ''

    name = family if !family.nil? && (family != '')

    if !pre_title.nil? && (pre_title != '')
      name = "#{name}, " if name != ''
      name = "#{name}#{pre_title}"
    end

    if !given_name.nil? && (given_name != '')
      name = "#{name}, " if name != ''
      name = "#{name}#{given_name}"
    end

    if !dates.nil? && (dates != '')
      name = "#{name}, " if name != ''
      name = "#{name}#{dates}"
    end

    if !post_title.nil? && (post_title != '')
      name = "#{name}, " if name != ''
      name = "#{name}#{post_title}"
    end

    if !epithet.nil? && (epithet != '')
      name = "#{name}, " if name != ''
      name = "#{name}#{epithet}"
    end

    name
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end
end
