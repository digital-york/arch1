class SubjectsController < ApplicationController

  before_filter :session_timed_out_small

  layout 'concepts'

  #INDEX
  def index

    if params[:start] == 'true' then session[:subject_search_term] = '' end

    # This variable identifies the 'Same As' field on the form (i.e. it is used when the user selects a 'subject')
    #if params[:subject_field] != nil
    #  session[:subject_field] = params[:subject_field]
    #end

    # Set the session search_term variable if it is passed as a parameter
    if params[:search_term] != nil then session[:subject_search_term] = params[:search_term] end

    # Get the top-level list (which contains the 2nd level and 3rd level lists)
    @top_level_list = SubjectTerms.new('subauthority').get_subject_list_top_level
  end

  # SHOW
  def show
    # Get the list for the particular top-level id
    @top_level_list = SubjectTerms.new('subauthority').get_subject_list_second_level(params[:id])
    @error = params[:error]
  end

  # NEW
  def new
    @concept = Concept.new
    @go_back_id = params[:go_back_id] # This is for the link to go back to the previous page (i.e. on the index, add or edit pages)
    @broader_id = params[:broader_id] # This creates an association between a subject and the parent subject
  end

  # EDIT
  def edit
    @concept = Concept.find(params[:id])
    @go_back_id = params[:go_back_id]
    @broader_id = @concept.broader
  end

  # CREATE
  def create

    # Check parameters are permitted
    subject_params = whitelist_subject_params

    @error = ''

    if subject_params[:preflabel] == ''
      @error = "Please enter a 'Subject'"
    end

    if @error != ''
      @concept = Concept.new(subject_params)
      @go_back_id = params[:go_back_id]
      @broader_id = params[:concept][:broader]
      render 'new'
    else

      # Create a new subject with the parameters
      @concept = Concept.new(subject_params)

      # Use a solr query to obtain the concept scheme id for 'subjects'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"Borthwick Institute for Archives Subject Headings"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @concept.concept_scheme_id = id

      @concept.save

      # Pass variable to view page to notify user that subject has been added
      @subject_name = @concept.preflabel

      # Initialise subject form again
      @concept = Concept.new

      if params[:concept][:istopconcept] == 'true'
        redirect_to :controller => 'subjects', :action => 'index', :subject_name => @subject_name
      else
        redirect_to :controller => 'subjects', :action => 'show', :id => params[:go_back_id], :subject_name => @subject_name
      end
    end
  end

  # UPDATE
  def update

    # Check parameters are permitted
    subject_params = whitelist_subject_params

    @error = ''

    if subject_params[:preflabel] == ''
      @error = "Please enter a 'Subject'"
    end

    # Get a concept object using the id and populate it with the subject parameters
    @concept = Concept.find(params[:id])
    @concept.attributes = subject_params

    if @error != ''
      @go_back_id = params[:go_back_id]
      @broader_id = params[:concept][:broader]
      render 'edit'
    else

      # Use a solr query to obtain the concept scheme id for 'subjects'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:"subjects"', fl='id', rows=1, sort='')
      id = response['response']['docs'][0]['id']
      @concept.concept_scheme_id = id

      @concept.save

      redirect_to :controller => 'subjects', :action => 'show', :id => params[:go_back_id]
    end
  end

  # DESTROY
  def destroy

    @concept = Concept.find(params[:id])

    # Check if the subject is present in any of the entries
    # If so, direct the user to a page with the entry locations so that they can remove them
    existing_location_list = get_existing_location_list('subject', @concept.id)

    if existing_location_list.size > 0
      render 'subject_exists_list', :locals => { :@subject_name => @concept.preflabel, :@existing_location_list => existing_location_list, :@go_back_id =>  params[:go_back_id] }
    else

      # Get the parent / child list for the specified id
      # The list should only contain the parent subject
      # If it contains children then an error message is displayed on the page to tell the user that they must delete them first
      parent_child_list = get_parent_child_list

      if parent_child_list.size > 1
        error = "'#{@concept.preflabel}' contains child elements - please delete them first"
        redirect_to :controller => 'subjects', :action => 'show', :id => params[:go_back_id], :error => error
      else
        @concept.destroy
        redirect_to :controller => 'subjects', :action => 'show', :id => params[:go_back_id]
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_subject_params
    params.require(:concept).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

end