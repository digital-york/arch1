# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :session_timed_out_small

  # INDEX
  def index
    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'group')
    @group_field = params[:group_field]

    # Set the search_term variable if it is passed as a parameter
    @search_term = ''
    @search_term = if !params[:search_term_index].nil?
                     params[:search_term_index]
                   else
                     params[:search_term]
                   end

    @search_array = []

    # Get Concepts for the group ConceptScheme and filter according to search_term
    num = SolrQuery.new.solr_query(q = 'has_model_ssim:Group', fl = 'id', rows = 0)['response']['numFound']
    SolrQuery.new.solr_query(q = 'has_model_ssim:Group', fl = 'id, preflabel_tesim', rows = num, sort = 'id asc')['response']['docs'].map.each do |result|
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
    @group = Group.new
    @search_term = params[:search_term]
    @group_field = params[:group_field]
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # EDIT
  def edit
    @group = Group.find(params[:id])
    @search_term = params[:search_term]
    @group_field = params[:group_field]
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # CREATE
  def create
    # Check parameters are permitted
    group_params = whitelist_group_params

    # Remove any empty fields
    remove_group_popup_empty_fields(group_params)

    @error = ''

    @error = 'Please enter a Name' if group_params[:name] == ''

    # Check that same_as is a URL
    @error = check_url(group_params[:same_as], @error, 'Same As')

    # Disable this check
    # Check that related_authority is a URL
    # @error = check_url(group_params[:related_authority], @error, "Related Authority")

    @group = Group.new(group_params)

    if @error != ''
      @search_term = params[:search_term]
      @group_field = params[:group_field]
      render 'new'
    else

      # Use a solr query to obtain the concept scheme id for 'groups'
      response = SolrQuery.new.solr_query(q = 'has_model_ssim:ConceptScheme AND preflabel_tesim:"groups"', fl = 'id', rows = 1, sort = '')
      id = response['response']['docs'][0]['id']
      @group.concept_scheme_id = id

      # Get preflabel, rdftype and save
      @group.preflabel = get_preflabel(@group.name, @group.dates, @group.qualifier)
      @group.rdftype << @group.add_rdf_types
      @group.save

      # If the 'Submit and Close' button has been clicked, pass these variables back to the page
      # so that the javascript method is run (i.e. post_value()) and the page is closed
      if params[:commit] == 'Submit and Close'
        @commit_id = @group.id
        @commit_group_name = group_params[:family]
      end

      redirect_to controller: 'groups', action: 'index', search_term: params[:search_term], group_field: params[:group_field]
    end
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # UPDATE
  def update
    # Check parameters are permitted
    group_params = whitelist_group_params

    # Remove any empty fields
    remove_group_popup_empty_fields(group_params)

    @error = ''

    @error = 'Please enter a Name' if group_params[:name] == ''

    # Check that same_as is a URL
    @error = check_url(group_params[:same_as], @error, 'Same As')

    # Disable this check
    # Check that related_authority is a URL
    # @error = check_url(place_params[:related_authority], @error, "Related Authority")

    # Get a group object using the id and populate it with the group parameters
    @group = Group.find(params[:id])
    @group.attributes = group_params

    if @error != ''
      @search_term = params[:search_term]
      @group_field = params[:group_field]
      render 'edit'
    else
      @group.preflabel = get_preflabel(@group.name, @group.dates, @group.qualifier)
      @group.save
      # solr update any related objects
      update_related('group', @group.id)
      redirect_to controller: 'groups', action: 'index', search_term: params[:search_term], group_field: params[:group_field]
    end
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  # DESTROY
  def destroy
    @group = Group.find(params[:id])

    # Check if the group is present in any of the entries
    # If so, direct the user to a page with the entry locations so that they can remove them
    existing_location_list = get_existing_location_list('person_same_as', @group.id)

    if !existing_location_list.empty?
      render 'group_exists_list', locals: { :@group_name => @group.name, :id => @group.id, :@existing_location_list => existing_location_list, :@go_back_id => params[:go_back_id], :@search_term => params[:search_term], :@group_field => params[:group_field] }
    else
      @group.destroy
      redirect_to controller: 'groups', action: 'index', search_term: params[:search_term], group_field: params[:group_field]
    end
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_group_params
    params.require(:group).permit(:name, :dates, :qualifier, :group_type, same_as: [], related_authority: [], altlabel: [], note: []) # Note - arrays need to go at the end or an error occurs!
  end

  # This method is used to get the preflabel and to get the label which is displayed on the view page
  # is_join is required if the data comes from solr, i.e. when getting the data to display on the view page
  def get_preflabel(name, dates, qualifier)
    preflabel = name
    if !dates.nil? && (dates != '')
      name = "#{name}, " if name != ''
      preflabel = "#{name}, #{dates}"
    end

    preflabel += ", #{qualifier}" if !qualifier.nil? && (qualifier != '')

    preflabel
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end
end
