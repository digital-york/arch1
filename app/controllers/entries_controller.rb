class EntriesController < ApplicationController

  before_filter :session_timed_out

  # INDEX
  def index

    # Set the folio and image session variables when a folio is chosen from the drop-down list
    if params[:set_folio] == 'true'
      set_folio_and_image_drop_down
    end

    # Set the @folio_list for the folio drop-down
    set_folio_list

    if session[:folio_id] != ''

      # Set the folio and image session variables when the '<' or '>' buttons are clicked
      if params[:small_zoom_action] != nil
        set_folio_and_image(params[:small_zoom_action], session[:folio_id])
      end

      # Get the first entry for the folio if there isn't an id
      # Else get the entry with the specified id
      if params[:id] == nil or params[:id] == ''
        @entry = Entry.where(folio_ssim: session[:folio_id]).first
      else
        @entry = Entry.find(params[:id])
      end

      # Check if this is the last entry for the folio
      # Determines if the 'Continues on next folio' row and 'Continues' button are displayed
      is_last_entry(@entry)

      # Determines if the 'New Entry' Tab and '(continues)' text are displayed
      set_folio_continues_id

      # Get all the entries which match with the chosen register, folio and folio face
      @entry_list = Entry.where(folio_ssim: session[:folio_id])
    end

  end

  # SHOW
  # This is called when the user selects an entry from the tabs (or when the 'discontinued' link is clicked)
  def show

    # Check if the discontinued link has been clicked for an entry
    if params[:discontinue] == 'true'
      @entry = Entry.find(params[:id])
      @entry.continues_on = nil
      @entry.save
      #@entry = Entry.find(params[:id])
    end

    redirect_to :controller => 'entries', :action => 'index', :id => params[:id]
  end

  # NEW
  def new

    # Create a new entry (but isn't saved to Fedora until the user clicks on submit)
    @entry = Entry.new

    # Set the entry no for the current folio
    max_entry_no = get_max_entry_no_for_folio
    @entry.entry_no = max_entry_no + 1

    # Get all the entries for this folio (so that they can be displayed as tabs)
    @entry_list = Entry.where(folio_ssim: session[:folio_id])

    # Set the authority lists (e.g. subject)
    set_authority_lists

    # Set the folio drop-down list
    set_folio_list

    # Check if this is the last entry for the folio
    # Determines if the 'Continues on next folio' row and 'Continues' button are displayed
    is_last_entry(@entry)

    # Determines which message is displayed on the 'Continue' button
    is_entry_on_next_folio

  end

  # EDIT
  def edit

    # Get all the entries for this folio (so that they can be displayed as tabs)
    @entry_list = Entry.all.where(folio_ssim: session[:folio_id])

    # Set the authority lists (e.g. subject)
    set_authority_lists

    # Set the folio drop-down list
    set_folio_list

    # Set the current entry
    @entry = Entry.find(params[:id])

    # Check if this is the last entry for the folio
    # Determines if the 'Continues on next folio' row and 'Continues' button are displayed
    is_last_entry(@entry)

    # Determines if the 'New Entry' Tab and '(continues)' text are displayed
    set_folio_continues_id

    # Determines which message is displayed on the 'Continue' button
    is_entry_on_next_folio

    # Define the related person list
    # Note that this is a dynamic list which has to be initialised before
    # editing the page so that the form displays the correct values
    @related_place_list = []

    # Add default select option to the related place list
    temp = []
    temp << '--- select ---'
    temp << ''
    @related_place_list << temp

    # Add other elements to the related place list, i.e. using RelatedPlace.place_as_written
    # Note - only add the first place_as_written at index [0] for each RelatedPlace
    @entry.related_places.each do |related_place|
      temp = []
      if related_place.place_as_written.count > 0
        temp << related_place.place_as_written[0]
        @related_place_list << temp
      end
    end

  end

  # CREATE
  def create

    # Redirects to 'index' when the user clicks the 'Back' button
    if params['commit'] == 'Back'
      redirect_to :controller => 'entries', :action => 'index', :id => ''
      return
    end

    # Update the rdf_types for all objects
    update_rdf_types

    # Check parameters are whitelisted
    entry_params = whitelist_entry_params

    # Get a new entry and replace values with the form parameters
    # Replace the folio id with the corresponding Folio object
    folio = Folio.where(id: entry_params['folio']).first
    entry_params['folio'] = folio

    # Remove any empty fields and blocks (date, place, person)
    remove_empty_fields(entry_params)

    # Check for errors
    @errors = check_for_errors(entry_params)

    # Populate new entry with the entry_params
    @entry = Entry.new(entry_params)

    # If there are errors, go back to the 'new' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil

      # Note: it would be better to 'redirect' to the 'edit' controller rather than 'render' to the 'edit' page
      # because we wouldn't have to set_authority_lists, etc, but 'redirect' loses the state of the nested form, i.e.
      # any fields which have been added are closed again??

      # Get all the entries for this folio (so that they can be displayed as tabs)
      @entry_list = Entry.all.where(folio_ssim: session[:folio_id])

      # Set the authority lists (e.g. subject)
      set_authority_lists

      # Set the folio drop-down list
      set_folio_list

      # Check if this is the last entry for the folio
      # Determines if the 'Continues on next folio' row and 'Continues' button are displayed
      is_last_entry(@entry)

      # Determines if the 'New Entry' Tab and '(continues)' text are displayed
      set_folio_continues_id

      # Determines which message is displayed on the 'Continue' button
      is_entry_on_next_folio

      # Add related place code freom 'edit' here?

      render 'new'

    else

      # If entry continues, create a new entry on the next folio and save
      # Also update the current entries 'continues_on' attribute
      next_entry_id = ''
      if params[:commit] == 'Continue'
        is_entry_on_next_folio
        next_entry_id = create_next_entry(@is_entry_on_next_folio)
      end

      @entry.rdftype = @entry.add_rdf_types
      @entry.save
      # add place relations onto people/groups
      update_related_places

      # If entry continues, redirect to the first entry on the next folio
      # Else redirect to the index page
      if next_entry_id != ''
        redirect_to :controller => 'entries', :action => 'edit', :id => next_entry_id
      else
        redirect_to :controller => 'entries', :action => 'index', :id => @entry.id
      end

    end
  end

  # UPDATE
  def update

    # Redirects to 'show' when the user clicks the 'Back to View' button
    if params['commit'] == 'Back to View'
      redirect_to :controller => 'entries', :action => 'show', :id => params[:id]
      return
    end

    # update the rdf_types for all objects
    update_rdf_types

    # Check parameters are whitelisted
    entry_params = whitelist_entry_params

    # Replace the folio id with the corresponding Folio object
    folio_id = Folio.where(id: entry_params['folio']).first
    entry_params['folio'] = folio_id

    # Remove any empty fields and blocks (date, place, person)
    remove_empty_fields(entry_params)

    # Check for errors
    @errors = check_for_errors(entry_params)

    # Get an entry object using the id and populate it with the entry parameters
    @entry = Entry.find(params[:id])
    @entry.attributes = entry_params

    # If there are errors, render the go back to the 'edit' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil

      # Note: it would be better to 'redirect' to the 'edit' controller rather than 'render' to the 'edit' page
      # because we wouldn't have to set_authority_lists, etc, but 'redirect' loses the state of the nested form, i.e.
      # any fields which have been added are closed again??

      # Get all the entries for this folio (so that they can be displayed as tabs)
      @entry_list = Entry.all.where(folio_ssim: session[:folio_id])

      # Set the authority lists (e.g. subject)
      set_authority_lists

      # Set the folio drop-down list
      set_folio_list

      # Check if this is the last entry for the folio
      # Determines if the 'Continues on next folio' row and 'Continues' button are displayed
      is_last_entry(@entry)

      # Determines if the 'New Entry' Tab and '(continues)' text are displayed
      set_folio_continues_id

      # Determines which message is displayed on the 'Continue' button
      is_entry_on_next_folio

      # Add related place code freom 'edit' here?

      # Render the edit page
      render 'edit'

    else

      # If entry continues, create a new entry on the next folio and save
      # Also update the current entries 'continues_on' attribute
      next_entry_id = ''
      if params[:commit] == 'Continue'
        is_entry_on_next_folio
        next_entry_id = create_next_entry(@is_entry_on_next_folio)
      end

      # Save form data to Fedora
      @entry.save
      update_related_places

      # If entry continues, redirect to the first entry on the next folio
      # Else redirect to the index page
      if next_entry_id != ''
        redirect_to :controller => 'entries', :action => 'edit', :id => next_entry_id
      else
        redirect_to :controller => 'entries', :action => 'index', :id => @entry.id
      end
    end
  end

  # DESTROY
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    redirect_to entries_path, notice: 'Entry deleted.'
  end

  # PRIVATE METHODS
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_entry_params
    params.require(:entry).permit! # Note - this needs changing because it allows through all params at the moment!!
    #params.require(:entry).permit(:entry_no, :access_provided_by, editorial_notes_attributes: [:id, :editorial_note, :_destroy], people_attributes: [:id, :name_as_written, :note, :age, :gender, :name_authority, :_destroy])
  end

  # Check if session has timed out
  # Note that the session timeout value is set in config/initializers/session_store.rb
  def session_timed_out
    if session[:login] != 'true'
      redirect_to :controller => 'login', :action => 'timed_out'
    end
  end

  private
  def update_rdf_types
    unless params[:entry][:related_person_groups_attributes].nil?
      params[:entry][:related_person_groups_attributes].each do | key, value|
        value.each do | k, v |
          if k == 'rdftype'
            params[:entry][:related_person_groups_attributes][key][k] = v.gsub!("[","").gsub!('"','').gsub!("]",'').gsub(' ','').split(',').collect { |s| s }
          end
        end
      end
    end
    unless params[:entry][:related_places_attributes].nil?
      params[:entry][:related_places_attributes].each do | key, value|
        value.each do | k, v |
          if k == 'rdftype'
            params[:entry][:related_places_attributes][key][k] = v.gsub!("[","").gsub!('"','').gsub!("]",'').gsub(' ','').split(',').collect { |s| s }
          end
        end
      end
    end
    unless params[:entry][:entry_dates_attributes].nil?
      params[:entry][:entry_dates_attributes].each do | key, value|
        value.each do | k, v |
          if k == 'rdftype'
            params[:entry][:entry_dates_attributes][key][k] = [v.gsub!("[","").gsub!('"','').gsub!("]",'').gsub(' ','')]
          end
          if k == 'single_dates_attributes'
            v.each do | ke,va |
              va.each do | keya, val|
                if keya == 'rdftype'
                  params[:entry][:entry_dates_attributes][key][k][ke][keya] = [val.gsub!("[","").gsub!('"','').gsub!("]",'').gsub(' ','')]
                end
              end
            end
          end
        end
      end
    end
  end

  # this method adds relatedPlaceFor relations to RelatedPersonGroups by looking up the RelatedPlace id for each person_related_place
  private
  def update_related_places
    begin
      q = 'relatedPlaceFor_ssim:"' + @entry.id + '"'
      SolrQuery.new.solr_query(q, 'id,place_as_written_tesim', 50)['response']['docs'].each do |result|
        q = 'relatedAgentFor_ssim:"' + @entry.id + '" AND person_related_place_tesim:"' + result['place_as_written_tesim'][0] + '"'
        begin
          SolrQuery.new.solr_query(q, 'id,person_related_place_tesim', 50)['response']['docs'].each do |res|
            place = RelatedPlace.where(id: result['id']).first
            places = place.related_person_group
            places += [RelatedPersonGroup.where(id: res['id']).first]
            place.related_person_group = places
            place.save
          end
        rescue
          #move along
        end
      end
    rescue
      #move along
    end
  end
end
