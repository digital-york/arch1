class ConceptsController < ApplicationController

  before_filter :session_timed_out_small

  layout 'admins'

  #INDEX
  def index

    # Set the list_type, e.g. 'data_role'
    @list_type = params[:list_type]

    # Set the search_term variable if it is passed as a parameter
    @search_term = ''
    if params[:search_term_index] != nil
      @search_term = params[:search_term_index]
    else
      @search_term = params[:search_term]
    end

    @search_array = []

    # Get Concepts for the ConceptScheme and filter according to search_term
    SolrQuery.new.solr_query(q='has_model_ssim:Concept AND inScheme_ssim:' + get_concept_scheme_id(@list_type), fl='id, preflabel_tesim, altlabel_tesim, definition_tesim', rows=1000, sort='id asc')['response']['docs'].map.each do |result|

      concept_id = result['id']
      preflabel = result['preflabel_tesim'].join

      if preflabel.match(/#{@search_term}/i)
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
        definition = result['definition_tesim']
        if definition != nil
          definition = definition.join
        end
        tt << definition
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
    @search_term = params[:search_term]
    @list_type = params[:list_type]
  end

  # EDIT
  def edit
    @concept = Concept.find(params[:id])
    @search_term = params[:search_term]
    @list_type = params[:list_type]
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
      @list_type = params[:list_type]
      @search_term = params[:search_term]
      #render 'new', :locals => { :@search_term => params[:search_term], :@list_type => params[:list_type] }
      render 'new'
    else
      @concept.concept_scheme_id = get_concept_scheme_id(params[:list_type])
      @concept.rdftype << @concept.add_rdf_types
      # {{JA}}
      # get the id
      # @concept.id << @concept.create_container_id(@concept.concept_scheme_id)
      # cs = ConceptScheme.find(@concept.concept_scheme_id)
      # @concept.concept_scheme << cs
      # cs += @concept
      # get the concept scheme
      # not save the concept itself
      @concept.save
      redirect_to :controller => 'concepts', :action => 'index', :search_term => params[:search_term], :list_type => params[:list_type]
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
      @search_term = params[:search_term]
      @list_type = params[:list_type]
      render 'edit'
    else
      @concept.save
      redirect_to :controller => 'concepts', :action => 'index', :search_term => params[:search_term], :list_type => params[:list_type]
    end
  end

  # DESTROY
  def destroy

    @concept = Concept.find(params[:id])

    # Check if the concept is present in any of the entries
    # If so, direct the user to a page with the entry locations so that they can remove them
    existing_location_list = get_existing_location_list(params[:list_type], @concept.id)

    if existing_location_list.size > 0
      render 'concept_exists_list', :locals => { :@concept_name => @concept.preflabel, :id => @concept.id, :@existing_location_list => existing_location_list, :@go_back_id =>  params[:go_back_id] , :@search_term => params[:search_term], :@list_type => params[:list_type] }
    else
      @concept.destroy
      redirect_to :controller => 'concepts', :action => 'index', :search_term => params[:search_term], :list_type => params[:list_type]
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_concept_params
    params.require(:concept).permit(:preflabel, :definition, :altlabel => []) # Note - arrays need to go at the end or an error occurs!
  end

end