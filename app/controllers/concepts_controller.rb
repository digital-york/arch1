class ConceptsController < ApplicationController

  before_filter :session_timed_out_small

  #INDEX
  def index

    @concept_type = params[:concept_type]

    # If the popup has just been opened, set the session variable to ''
    #if params[:start] == 'true' or params[:list_type] == '--- select ---'
#
    #  session[:concept_list_type] = nil
     # session[:concept_search_term] = nil

    # Else do a search using the params[:search_term] or session[place_search_term]
    #else

      # Update the session variable with the new list type and search term
      if params[:list_type] != nil then session[:concept_list_type] = params[:list_type] end
      if params[:search_term] != nil then session[:concept_search_term] = params[:search_term] end

      @search_array = []

      # Get Concepts for this ConceptScheme
      SolrQuery.new.solr_query(q='has_model_ssim:Concept AND inScheme_ssim:' + get_concept_scheme_id, fl='id, preflabel_tesim, altlabel_tesim, description_tesim', rows=1000, sort='id asc')['response']['docs'].map.each do |result|
        concept_id = result['id']
        preflabel = result['preflabel_tesim'].join
        if preflabel.match(/#{session[:concept_search_term]}/i)
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

      # Sort the array
      @search_array = @search_array.sort_by { |k| k[1] }
    #end
  end

  # SHOW
  def show
    @concept = Concept.find(params[:id])
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

    if @error != ''
      @concept = Concept.new(concept_params)
    else

      # Create a new concept and save
      @concept = Concept.new(concept_params)
      @concept.concept_scheme_id = get_concept_scheme_id
      @concept.save

      # Pass variable to view page to notify user that place has been added.
      @concept_name = @concept.preflabel

      # Initialise form again
      @concept = Concept.new
    end

    render 'new'
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

    # Get a place object using the id and populate it with the place parameters
    @concept = Concept.find(params[:id])
    @concept.attributes = concept_params

    if @error != ''
      render 'edit'
    else

      # Save the concept
      @concept.concept_scheme_id = get_concept_scheme_id
      @concept.save

      # Pass variable to view page to notify user that place has been updated.
      @concept_name = @concept.preflabel
      puts @concept_name

      render 'edit'
    end
  end

  # DESTROY
  def destroy
    @concept = Concept.find(params[:id])
    @concept.destroy
    redirect_to :controller => 'concepts', :action => 'index'
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_concept_params
    params.require(:concept).permit! # Note - this needs changing because it allows through all params at the moment!!
  end

  def get_concept_scheme_id
    concept_list_type = "#{session[:concept_list_type].downcase}s"
    concept_list_type = concept_list_type.sub ' ', '_'
    response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:' + concept_list_type, fl='id', rows=1, sort='')
    concept_scheme_id = response['response']['docs'][0]['id']
    return concept_scheme_id
  end

end