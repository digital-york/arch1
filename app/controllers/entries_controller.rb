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
          SolrQuery.new.solr_query('folio_ssim:"' + session[:folio_id] + '"', 'id', 1, 'id asc')['response']['docs'].map do |result|
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
      end
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
    end

    redirect_to :controller => 'entries', :action => 'index', :id => params[:id]
  end

  # NEW
  def new

    # Create a new ActiveRecord entry
    @db_entry = DbEntry.new

    # Set the next entry_no
    @db_entry.entry_no = get_max_entry_no_for_folio + 1

    # Set various lists, e.g. authority_list, folio_list
    set_lists(@db_entry)

    # This tells the _form.html.erb page that this is a 'new' entry
    @form_type = 'NEW'

  end

  # EDIT
  def edit

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
    # Note - only add the first place_as_written at index [0] for each RelatedPlace (because there can be more than one)
    @db_entry.db_related_places.each do |related_place|
      temp = []
      if related_place.db_place_as_writtens[0] != nil
        temp << related_place.db_place_as_writtens[0].name
        @related_place_list << temp
      end
    end

    # This tells the _form.html.erb page that this is an 'edit' entry
    @form_type = 'EDIT'

  end

  # CREATE
  def create

    # Redirect back to the index page if the user has clciked the 'Back' button
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

      # Set various lists, e.g. authority_list, folio_list
      set_lists(@entry)

      # Note: it would be better to 'redirect' to the 'edit' controller rather than 'render' to the 'edit' page
      # because we wouldn't have to set_authority_lists, etc, but 'redirect' loses the state of the nested form, i.e.
      # it seems that any fields which have been added with the + buttons are closed again
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

      # Add place relations onto people/groups
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

    params[:id] = 'test:' + params[:id]

    # Redirects to 'show' when the user clicks the 'Back to View' button
    if params['commit'] == 'Back to View'
      redirect_to :controller => 'entries', :action => 'show', :id => params[:id]
      return
    end

    # Update the rdf_types for all objects
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

      # Set various lists, e.g. authority_list, folio_list
      set_lists(@entry)

      # Note: it would be better to 'redirect' to the 'edit' controller rather than 'render' to the 'edit' page
      # because we wouldn't have to set_authority_lists, etc, but 'redirect' loses the state of the nested form, i.e.
      # any fields which have been added are closed again??
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
    redirect_to entries_path
  end

  # PRIVATE METHODS
  private

  # Set various lists, e.g. authority_list, folio_list
  def set_lists(entry)

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
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def whitelist_entry_params
    params.require(:entry).permit! # Note - this needs changing because it allows through all params at the moment!!
    #params.require(:entry).permit(:entry_no, :access_provided_by, editorial_notes_attributes: [:id, :editorial_note, :_destroy], people_attributes: [:id, :name_as_written, :note, :age, :gender, :name_authority, :_destroy])
  end

  def get_solr_data(db_entry)

    SolrQuery.new.solr_query('id:' + db_entry.entry_id, 'entry_no_tesim, entry_type_tesim, section_type_tesim, continues_on_tesim, summary_tesim, marginalia_tesim, language_tesim, subject_tesim, note_tesim, editorial_note_tesim, is_referenced_by_tesim', 1)['response']['docs'].map do |result|

      if result['entry_no_tesim'] != nil

        db_entry.id = db_entry.entry_id.gsub(/test:/, '').to_i

        db_entry.entry_no = result['entry_no_tesim'].join()

        if result['entry_type_tesim'] != nil
          db_entry.entry_type = result['entry_type_tesim'].join()
        end

        section_type_list = result['section_type_tesim'];

        if section_type_list != nil
          section_type_list.each do |tt|
            db_section_type = DbSectionType.new
            db_section_type.name = tt
            db_entry.db_section_types << db_section_type
          end
        end

        if result['continues_on_tesim'] != nil
          db_entry.continues_on = result['continues_on_tesim'].join()
        end

        summary = result['summary_tesim']

        if summary != nil
          db_entry.summary = summary.join()
        end

        marginalium_list = result['marginalia_tesim'];

        if marginalium_list != nil
          marginalium_list.each do |tt|
            db_marginalium = DbMarginalium.new
            db_marginalium.name = tt
            db_entry.db_marginalia << db_marginalium
          end
        end

        language_list = result['language_tesim'];

        if language_list != nil
          language_list.each do |tt|
            db_language = DbLanguage.new
            db_language.name = tt
            db_entry.db_languages << db_language
          end
        end

        subject_list = result['subject_tesim'];

        if subject_list != nil
          subject_list.each do |tt|
            db_subject = DbSubject.new
            db_subject.name = tt
            db_entry.db_subjects << db_subject
          end
        end

        note_list = result['note_tesim'];

        if note_list != nil
          note_list.each do |tt|
            db_note = DbNote.new
            db_note.name = tt
            db_entry.db_notes << db_note
          end
        end

        editorial_note_list = result['editorial_note_tesim'];

        if editorial_note_list != nil
          editorial_note_list.each do |tt|
            db_editorial_note = DbEditorialNote.new
            db_editorial_note.name = tt
            db_entry.db_editorial_notes << db_editorial_note
          end
        end

        is_referenced_by_list = result['is_referenced_by_tesim'];

        if is_referenced_by_list != nil
          is_referenced_by_list.each do |tt|
            db_is_referenced_by = DbIsReferencedBy.new
            db_is_referenced_by.name = tt
            db_entry.db_is_referenced_bys << db_is_referenced_by
          end
        end

        SolrQuery.new.solr_query('has_model_ssim:EntryDate AND entryDateFor_ssim:' + db_entry.entry_id, 'id, date_role_tesim, date_note_tesim', 100)['response']['docs'].map do |result|

          date_id = result['id'];

          if date_id != nil

            db_entry_date = DbEntryDate.new

            db_entry_date.id = date_id.gsub(/test:/, '').to_i

            SolrQuery.new.solr_query('has_model_ssim:SingleDate AND dateFor_ssim:' + date_id, 'id, date_tesim, date_type_tesim, date_certainty_tesim', 100)['response']['docs'].map do |result2|

              single_date_id = result2['id'];

              if single_date_id != nil

                db_single_date = DbSingleDate.new

                db_single_date.id = single_date_id.gsub(/test:/, '').to_i

                date_certainty_list = result2['date_certainty_tesim'];

                if date_certainty_list != nil
                  date_certainty_list.each do |tt|
                    db_date_certainty = DbDateCertainty.new
                    db_date_certainty.name = tt
                    db_single_date.db_date_certainties << db_date_certainty
                  end
                end

                date = result2['date_tesim']

                if date != nil
                  db_single_date.date = date.join()
                end

                date_type = result2['date_type_tesim']

                if date_type != nil
                  db_single_date.date_type = date_type.join()
                end

                db_entry_date.db_single_dates << db_single_date
              end
            end

            date_role = result['date_role_tesim']

            if date_role != nil
              db_entry_date.date_role = date_role.join()
            end

            date_note = result['date_note_tesim']

            if date_note != nil
              db_entry_date.date_note = date_note.join()
            end

            db_entry.db_entry_dates << db_entry_date
          end
        end

        SolrQuery.new.solr_query('has_model_ssim:RelatedPlace AND relatedPlaceFor_ssim:"' + db_entry.entry_id + '"', 'id, place_same_as_tesim, place_as_written_tesim, place_role_tesim, place_type_tesim, place_note_tesim', 100)['response']['docs'].map do |result|

          related_place_id = result['id'];

          if related_place_id != nil

            db_related_place = DbRelatedPlace.new

            db_related_place.id = related_place_id.gsub(/test:/, '').to_i

            place_same_as = result['place_same_as_tesim']

            if place_same_as != nil
              db_related_place.place_same_as = place_same_as.join()
            end

            place_as_written_list = result['place_as_written_tesim'];

            if place_as_written_list != nil
              place_as_written_list.each do |tt|
                db_place_as_written = DbPlaceAsWritten.new
                db_place_as_written.name = tt
                db_related_place.db_place_as_writtens << db_place_as_written
              end
            end

            place_role_list = result['place_role_tesim'];

            if place_role_list != nil
              place_role_list.each do |tt|
                db_place_role = DbPlaceRole.new
                db_place_role.name = tt
                db_related_place.db_place_roles << db_place_role
              end
            end

            place_type_list = result['place_type_tesim'];

            if place_type_list != nil
              place_type_list.each do |tt|
                db_place_type = DbPlaceType.new
                db_place_type.name = tt
                db_related_place.db_place_types << db_place_type
              end
            end

            place_note_list = result['place_note_tesim'];

            if place_note_list != nil
              place_note_list.each do |tt|
                db_place_note = DbPlaceNote.new
                db_place_note.name = tt
                db_related_place.db_place_notes << db_place_note
              end
            end

            db_entry.db_related_places << db_related_place
          end
        end

        SolrQuery.new.solr_query('has_model_ssim:RelatedPersonGroup AND relatedAgentFor_ssim:"' + db_entry.entry_id + '"', 'id, person_same_as_tesim, person_gender_tesim, person_as_written_tesim, person_role_tesim, person_descriptor_tesim, person_descriptor_as_written_tesim, person_note_tesim, person_related_place_tesim', 100)['response']['docs'].map do |result|

          related_person_group_id = result['id'];

          if related_person_group_id != nil

            db_related_person_group = DbRelatedPersonGroup.new

            db_related_person_group.id = related_person_group_id.gsub(/test:/, '').to_i

            person_same_as = result['person_same_as_tesim']

            if person_same_as != nil
              db_related_person_group.person_same_as = person_same_as.join()
            end

            person_gender = result['person_gender_tesim']

            if person_gender != nil
              db_related_person_group.person_gender = person_gender.join()
            end

            person_as_written_list = result['person_as_written_tesim'];

            if person_as_written_list != nil
              person_as_written_list.each do |tt|
                db_person_as_written = DbPersonAsWritten.new
                db_person_as_written.name = tt
                db_related_person_group.db_person_as_writtens << db_person_as_written
              end
            end

            person_role_list = result['person_role_tesim'];

            if person_role_list != nil
              person_role_list.each do |tt|
                db_person_role = DbPersonRole.new
                db_person_role.name = tt
                db_related_person_group.db_person_roles << db_person_role
              end
            end

            person_descriptor_list = result['person_descriptor_tesim'];

            if person_descriptor_list != nil
              person_descriptor_list.each do |tt|
                db_person_descriptor = DbPersonDescriptor.new
                db_person_descriptor.name = tt
                db_related_person_group.db_person_descriptors << db_person_descriptor
              end
            end

            person_descriptor_as_written_list = result['person_descriptor_as_written_tesim'];

            if person_descriptor_as_written_list != nil
              person_descriptor_as_written_list.each do |tt|
                db_person_descriptor_as_written = DbPersonDescriptorAsWritten.new
                db_person_descriptor_as_written.name = tt
                db_related_person_group.db_person_descriptor_as_writtens << db_person_descriptor_as_written
              end
            end

            person_note_list = result['person_note_tesim'];

            if person_note_list != nil
              person_note_list.each do |tt|
                db_person_note = DbPersonNote.new
                db_person_note.name = tt
                db_related_person_group.db_person_notes << db_person_note
              end
            end

            person_related_place_list = result['person_related_place_tesim'];

            if person_related_place_list != nil
              person_related_place_list.each do |tt|
                db_person_related_place = DbPersonRelatedPlace.new
                db_person_related_place.name = tt
                db_related_person_group.db_person_related_places << db_person_related_place
              end
            end

            db_entry.db_related_person_groups << db_related_person_group
          end
        end

      end
    end
  end
end
