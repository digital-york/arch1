class EntriesController < ApplicationController

  include PlacesHelper

  before_filter :session_timed_out

  # INDEX
  def index

    begin

      # Set the folio and image session variables when a folio is chosen from the drop-down list
      if params[:set_folio] == 'true'
        set_folio_and_image_drop_down
      end

      # Set the @folio_list for the folio drop-down
      set_folio_list

      # Do this if a folio has been chosen...
      if session[:folio_id] != ''

        # Set the folio and image session variables when the '<' or '>' buttons are clicked
        if params[:small_zoom_action] != nil
          set_folio_and_image(params[:small_zoom_action], session[:folio_id])
        end

        # Set the entry tab list (i.e. at the top of the form)
        set_entry_list

        if @entry_list.length > 0

          # Create top-level ActiveRecord object
          @db_entry = DbEntry.new

          # Get the first entry for the folio if there isn't an id
          # Else get the specified entry
          if params[:id] == nil or params[:id] == ''
            SolrQuery.new.solr_query('folio_ssim:"' + session[:folio_id] + '"', 'id', 1, 'entry_no_si asc')['response']['docs'].map do |result|
              @db_entry.entry_id = result['id']
            end
          else
            @db_entry.entry_id = params[:id]
          end

          # Populate db_entry with data from Solr
          get_solr_data(@db_entry)

          # Check if this is the last entry for the folio
          # Determines if the 'Continues on next folio' row and 'Continues' button are to be displayed
          is_last_entry(@db_entry)

          # Determine if the 'New Entry' Tab and '(continues)' text are to be displayed
          set_folio_continues_id

          # Determines if this is the last entry on a folio which is continued from the previous folio
          # i.e. the previous folio 'continues_on' field is populated
          is_last_entry_for_continues_on(@db_entry)
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # SHOW
  # This is called when the user selects an entry from the tabs (or when the 'discontinued' link is clicked)
  def show

    begin

      # Check if the discontinued link has been clicked for an entry
      if params[:discontinue] == 'true'
        @entry = Entry.find(params[:id])
        @entry.continues_on = nil
        @entry.save
      end

      redirect_to :controller => 'entries', :action => 'index', :id => params[:id]

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # NEW
  def new

    begin

      # Create a new ActiveRecord entry
      @db_entry = DbEntry.new

      # Set the next entry_no
      @db_entry.entry_no = get_max_entry_no_for_folio + 1

      # Set various lists, e.g. authority_list, folio_list
      set_lists(@db_entry)

      # This tells the _form.html.erb page that this is a 'new' entry
      @form_type = 'NEW'

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # EDIT
  def edit

    begin

      # Create a new ActiveRecord entry
      @db_entry = DbEntry.new
      @db_entry.entry_id = params[:id]

      # Populate db_entry with data from Solr
      get_solr_data(@db_entry)

      # Set various lists, e.g. authority_list, folio_list
      set_lists(@db_entry)

      # Define the related person list
      # Note that this is a dynamic list which has to be initialised before editing
      # the page so that the form displays the correct values
      @related_place_list = []

      # Add default select option to the related place list
      temp = []
      temp << '--- select ---'
      temp << ''
      @related_place_list << temp

      # Add other elements to the related place list, i.e. using RelatedPlace.place_as_written
      # Note - only add the first place_as_written at index [0] for each Related Place (because there can be more than one)
      @db_entry.db_related_places.each do |related_place|
        temp = []
        if related_place.db_place_as_writtens[0] != nil
          temp << related_place.db_place_as_writtens[0].name
          @related_place_list << temp
        end
      end

      @related_person_list = []

      # Add default select option to the related person list
      temp = []
      temp << '--- select ---'
      temp << ''
      @related_person_list << temp

      # Add other elements to the related place list, i.e. using RelatedPlace.place_as_written
      # Note - only add the first place_as_written at index [0] for each Related Place (because there can be more than one)
      @db_entry.db_related_agents.each do |related_person|
        temp = []
        if related_person.db_person_as_writtens[0] != nil
          temp << related_person.db_person_as_writtens[0].name
          @related_person_list << temp
        end
      end

      # This tells the _form.html.erb page that this is an 'edit' entry
      @form_type = 'EDIT'

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # CREATE
  def create

    begin

      # Redirect back to the index page if the user has clicked the 'Back' button
      if params['commit'] == 'Back'
        redirect_to :controller => 'entries', :action => 'index', :id => ''
        return
      end

      # Check parameters are whitelisted
      entry_params = whitelist_entry_params

      # Get a new entry and replace values with the form parameters
      # Replace the folio id with the corresponding Folio object
      folio = Folio.find(entry_params['folio'])
      entry_params['folio'] = folio

      # Remove the entry_id
      entry_params.delete(:entry_id)

      # Remove the additional id fields
      unless entry_params["related_agents_attributes"].nil?
        entry_params["related_agents_attributes"].each do |p|
          entry_params["related_agents_attributes"][p[0]].delete(:person_id)
        end
      end
      unless entry_params["related_places_attributes"].nil?
        entry_params["related_places_attributes"].each do |p|
          entry_params["related_places_attributes"][p[0]].delete(:place_id)
          # Check if the place is from DEEP, if yes, store locally
          if entry_params["related_places_attributes"][p[0]]['place_same_as'].start_with? 'deep_'
            entry_params["related_places_attributes"][p[0]]['place_same_as'] = check_id(entry_params["related_places_attributes"][p[0]]['place_same_as'])
          end
        end
      end
      unless entry_params["entry_dates_attributes"].nil?
        entry_params["entry_dates_attributes"].each do |p|
          entry_params["entry_dates_attributes"][p[0]].delete(:date_id)
          if entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"] == ''
            entry_params["entry_dates_attributes"][p[0]].delete(:single_dates_attributes)
          end
          unless entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"].nil? or entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"] == ''
            entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"].each do |s|
              entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"][s[0]].delete(:single_date_id)
            end
          end
        end
      end

      # Update the rdf_types for all objects
      entry_params = update_rdf_types(entry_params)

      # Remove any empty fields and blocks (date, place, person)
      remove_empty_fields(entry_params)

      # Check for errors
      #@errors = check_for_errors(entry_params)

      # Populate new entry with the entry_params
      @entry = Entry.new(entry_params)

      # If there are errors, go back to the 'new' page and display the errors, else go to the 'index' page
      if @errors != '' && @errors != nil
        # No checks
      else

        # If entry continues, create a new entry on the next folio and save
        # Also update the current entries 'continues_on' attribute
        next_entry_id = ''
        if params[:commit] == 'Continue'
          is_entry_on_next_folio
          next_entry_id = create_next_entry(@is_entry_on_next_folio)
        end

        # Add rdftype and save
        @entry.rdftype << @entry.add_rdf_types
        @entry.save

        # These methods link people and places to Related People
        update_related_places
        update_related_people

        # Mark any new person, place or group authorities 'used'
        update_new_people_group
        update_new_place

        # If entry continues, redirect to the first entry on the next folio, else redirect to the index page
        if next_entry_id != ''
          redirect_to :controller => 'entries', :action => 'edit', :id => next_entry_id
        else
          redirect_to :controller => 'entries', :action => 'index', :id => @entry.id
        end

      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # UPDATE
  def update

    begin

      # Redirects to 'show' when the user clicks the 'Back to View' button
      if params['commit'] == 'Back to View'
        redirect_to :controller => 'entries', :action => 'show', :id => params[:entry][:entry_id]
        return
      end

      # Check parameters are whitelisted
      entry_params = whitelist_entry_params

      # Replace the folio id with the corresponding Folio object
      folio_id = Folio.find(entry_params['folio'])
      entry_params['folio'] = folio_id

      # Remove the entry_id
      entry_params.delete(:entry_id)

      # Assign and Remove the additional id fields
      unless entry_params["related_agents_attributes"].nil?
        entry_params["related_agents_attributes"].each do |p|
          entry_params["related_agents_attributes"][p[0]]['id'] = entry_params["related_agents_attributes"][p[0]]['person_id']
          entry_params["related_agents_attributes"][p[0]].delete(:person_id)
        end
      end
      unless entry_params["related_places_attributes"].nil?
        entry_params["related_places_attributes"].each do |p|
          entry_params["related_places_attributes"][p[0]]['id'] = entry_params["related_places_attributes"][p[0]]['place_id']
          entry_params["related_places_attributes"][p[0]].delete(:place_id)
          # Check if the place is from DEEP, if yes, store locally
          if entry_params["related_places_attributes"][p[0]]['place_same_as'].start_with? 'deep_'
            entry_params["related_places_attributes"][p[0]]['place_same_as'] = check_id(entry_params["related_places_attributes"][p[0]]['place_same_as'])
          end
        end
      end
      unless entry_params["entry_dates_attributes"].nil?
        entry_params["entry_dates_attributes"].each do |p|
          entry_params["entry_dates_attributes"][p[0]]['id'] = entry_params["entry_dates_attributes"][p[0]]['date_id']
          entry_params["entry_dates_attributes"][p[0]].delete(:date_id)
          unless entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"].nil? or entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"] == ''
            entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"].each do |s|
              entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"][s[0]]['id'] =
                  entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"][s[0]]['single_date_id']
              entry_params["entry_dates_attributes"][p[0]]["single_dates_attributes"][s[0]].delete(:single_date_id)
            end
          end
        end
      end

      # Update the rdf_types for all objects
      entry_params = update_rdf_types(entry_params)

      # Remove any empty fields and blocks (date, place, person)
      remove_empty_fields(entry_params)

      # Check for errors
      #@errors = check_for_errors(entry_params)

      # Get an entry object using the id and populate it with the entry parameters
      @entry = Entry.find(params[:entry][:entry_id])

      @entry.attributes = entry_params

      # If there are errors, render the go back to the 'edit' page and display the errors, else go to the 'index' page
      if @errors != '' && @errors != nil
        # No checks
      else

        # If entry continues, create a new entry on the next folio and save
        # Also update the current entries 'continues_on' attribute
        next_entry_id = ''
        if params[:commit] == 'Continue'
          is_entry_on_next_folio
          next_entry_id = create_next_entry(@is_entry_on_next_folio)
        end

        # Save entry
        @entry.save

        # These methods link people and places to Related People
        update_related_places
        update_related_people

        # Mark any new person, place or group authorities 'used'
        update_new_people_group
        update_new_place

        # If entry continues, redirect to the first entry on the next folio
        # Else redirect to the index page
        if next_entry_id != ''
          redirect_to :controller => 'entries', :action => 'edit', :id => next_entry_id
        else
          redirect_to :controller => 'entries', :action => 'index', :id => @entry.id
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # DESTROY
  def destroy

    begin

      @entry = Entry.find(params[:id])

      can_delete = true

      SolrQuery.new.solr_query('continues_on_tesim:' + session[:folio_id], 'id', 1, 'entry_no_si asc')['response']['docs'].map do |result|
        entry_count = SolrQuery.new.solr_query('folio_ssim:' + session[:folio_id], 'id', 100, 'id asc')['response']['docs'].map.size
        if entry_count <= 1
          can_delete = false
        end
      end

      if can_delete == true
        @entry.destroy
      else
        delete_error = "Please 'Discontinue' the last entry on the previous folio before deleting this entry"
      end

      redirect_to :controller => 'entries', :action => 'index', :delete_error => delete_error

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # PRIVATE METHODS
  private

  # Set various lists, e.g. authority_list, folio_list
  def set_lists(entry)

    begin

      # Set the folio drop-down list
      set_folio_list

      # Set the authority lists (e.g. subject)
      set_authority_lists

      # Set the entry tab list (i.e. at the top of the form)
      set_entry_list

      # Determines if the 'Continues on next folio' row and 'Continues' button are to be displayed
      is_last_entry(entry)

      # Determines if the 'New Entry' Tab and '(continues)' text are to be displayed
      set_folio_continues_id

      # Determines which message is displayed when the user clicks the 'Continue' button
      is_entry_on_next_folio

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # Note - I think arrays have to go after the single fields otherwise it doesn't work
  def whitelist_entry_params
    params.require(:entry).permit(:folio, :entry_no, :entry_id, :summary, :rdftype => [], :entry_type => [], :section_type => [], :marginalia => [], :language => [], :subject => [], :note => [], :editorial_note => [], :is_referenced_by => [],
                                  :entry_dates_attributes => [:id, :_destroy, :date_id, :date_role, :date_note, :rdftype => [], :single_dates_attributes => [:id, :_destroy, :single_date_id, :date, :date_type, :rdftype => [], :date_certainty => []]],
                                  :related_places_attributes => [:id, :_destroy, :place_id, :place_same_as, :rdftype => [], :place_as_written => [], :place_role => [], :place_type => [], :place_note => []],
                                  :related_agents_attributes => [:id, :_destroy, :person_id, :person_same_as, :person_group, :person_gender, :rdftype => [], :person_as_written => [], :person_role => [], :person_descriptor => [], :person_descriptor_as_written => [], :person_note => [], :person_related_place => [], :person_related_person => []])
  end

end
