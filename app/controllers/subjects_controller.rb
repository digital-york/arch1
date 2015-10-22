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
    # Find all child subjects and destroy
    delete_list = get_deleted_ids
    if delete_list.size > 1
     #redirect_to :controller => 'subjects', :action => 'delete_confirm', :id => params[:go_back_id], :delete_list => delete_list
      error = "'#{@concept.preflabel}' contains child elements - please delete them first"
      redirect_to :controller => 'subjects', :action => 'show', :id => params[:go_back_id], :error => error
    else
      # Check if the subject is present in any of the entries
      subject_location_list = get_subject_locations
      if subject_location_list.size > 0
        render 'subject_exists_list', :locals => { :@subject => @concept.preflabel, :@delete_list => subject_location_list, :@go_back_id =>  params[:go_back_id] }
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

  def get_subject_locations

    subject_location_list = []

    SolrQuery.new.solr_query(q='subject_tesim:' + @concept.id, fl='id, folio_ssim, entry_no_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
      id = result['id']
      folio_id = result['folio_ssim'].join
      entry_no = result['entry_no_tesim'].join
      folio = SolrQuery.new.solr_query(q='id:' + folio_id, fl='preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map.first['preflabel_tesim'].join
      #puts "#{id} - #{folio} - #{entry_no}"
      subject_location_list << folio + ' (Entry No = ' + entry_no + ')'
    end

    return subject_location_list
  end

  def get_deleted_ids

    delete_list = {}
    delete_list[@concept.id] = @concept.preflabel

    SolrQuery.new.solr_query(q='broader_tesim:' + @concept.id, fl='id, preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
      id = result['id']
      preflabel = result['preflabel_tesim'].join
      delete_list[id] = preflabel
      SolrQuery.new.solr_query(q='broader_tesim:' + id, fl='id, preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
        id2 = result['id']
        preflabel2 = result['preflabel_tesim'].join
        delete_list[id2] = preflabel2
      end
    end

   return delete_list
  end

end