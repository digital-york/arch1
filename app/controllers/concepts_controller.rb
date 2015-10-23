class ConceptsController < ApplicationController

  before_filter :session_timed_out_small

  #INDEX
  def index

    # Only set the session variables if they are passed as parameters, i.e. when
    # this comes from the search page (this 'index' action can also be called from the add and edit pages)
    if params[:list_type] != nil then session[:list_type] = params[:list_type] end
    if params[:search_term] != nil then session[:search_term] = params[:search_term] end

    @search_array = []

    # Get Concepts for the ConceptScheme and filter according to search_term
    SolrQuery.new.solr_query(q='has_model_ssim:Concept AND inScheme_ssim:' + get_concept_scheme_id, fl='id, preflabel_tesim, altlabel_tesim, description_tesim', rows=1000, sort='id asc')['response']['docs'].map.each do |result|

      concept_id = result['id']
      preflabel = result['preflabel_tesim'].join

      if preflabel.match(/#{session[:search_term]}/i)
        tt = []
        tt << concept_id
        tt << preflabel
        altlabel = result['altlabel_tesim']
        if altlabel != nil
          altlabel = altlabel
        else
          altlabel = []
        end
        tt << altlabel
        description = result['description_tesim']
        if description != nil
          description = description.join
        end
        tt << description
        @search_array << tt
      end
    end

    # Sort the array by preflabel
    @search_array = @search_array.sort_by { |k| k[1] }

  end

  # SHOW
  def show
  end

  # NEW
  def new
    @concept = Concept.new
  end

  # EDIT
  def edit
    @concept = Concept.find(params[:id])
  end

  # CREATE
  def create

    # Check parameters are permitted
    concept_params = whitelist_concept_params

    # Remove any empty fields
    remove_concept_popup_empty_fields(concept_params)

    @error = ''

    if concept_params[:preflabel] == ''
      @error = "Please enter a 'Label'"
    end

    @concept = Concept.new(concept_params)

    if @error != ''
      render 'new'
    else
      @concept.concept_scheme_id = get_concept_scheme_id
      @concept.save
      redirect_to :controller => 'concepts', :action => 'index'
    end
  end

  # UPDATE
  def update

    # Check parameters are permitted
    concept_params = whitelist_concept_params

    # Remove any empty fields
    remove_concept_popup_empty_fields(concept_params)

    @error = ''

    if concept_params[:preflabel] == ''
      @error = "Please enter a 'Label'"
    end

    # Get a concept object using the id and populate it with the concept parameters
    @concept = Concept.find(params[:id])
    @concept.attributes = concept_params

    if @error != ''
      render 'edit'
    else

      # Save the concept
      @concept.concept_scheme_id = get_concept_scheme_id
      @concept.save

      redirect_to :controller => 'concepts', :action => 'index'
    end
  end

  # DESTROY
  def destroy

    @concept = Concept.find(params[:id])

    # Check if the concept is present in any of the entries
    # If so, direct the user to a page with the entry locations so that they can remove them
    existing_location_list = get_existing_location_list(session[:list_type])
    if existing_location_list.size > 0
      render 'concept_exists_list', :locals => { :@concept_name => @concept.preflabel, :@existing_location_list => existing_location_list, :@go_back_id =>  params[:go_back_id] }
    else
      @concept.destroy
      redirect_to :controller => 'concepts', :action => 'index'
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_concept_params
    params.require(:concept).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

end