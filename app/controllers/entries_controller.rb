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
      if params[:id] == nil
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
    set_entry

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

    # See validation.rb in /concerns
    #@errors = validate(entry_params)

    # Get a new entry and replace values with the form parameters
    # Replace the folio id with the corresponding Folio object
    folio = Folio.where(id: entry_params['folio']).first
    entry_params['folio'] = folio
    @entry = Entry.new(entry_params)

    # If there are errors, go back to the 'new' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil
      @entry_list = Entry.where(folio_ssim: session[:folio_id])
      set_authority_lists
      render 'new'
    else

      # Remove any multivalue blank fields or they will be submitted to Fedora
      remove_multivalue_blanks

      # If entry continues, create a new entry on the next folio and save
      # Also update the current entries 'continues_on' attribute
      next_entry_id = ''
      if params[:commit] == 'Continue'
        is_entry_on_next_folio
        next_entry_id = create_next_entry(@is_entry_on_next_folio)
      end

      @entry.save

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

    set_entry

    # See validation.rb in /concerns
    #@errors = validate(entry_params)

    # Replace the folio id with the corresponding Folio object
    folio_id = Folio.where(id: entry_params['folio']).first
    entry_params['folio'] = folio_id

    @entry.attributes = entry_params

    # If there are errors, render the go back to the 'edit' page and display the errors, else go to the 'index' page
    #if @errors != '' && @errors != nil
    #  @@entry_list = Entry.where(folio_ssim: session[:folio_id])
    #  set_authority_lists
    #  #@entry.attributes = entry_params # Updates the @entry with the appropriate attributes before rendering the 'edit' page
    #  set_entry
    #  set_folio_list
    #  render 'edit'
    #else

    # Remove any multivalue blank fields or they will be submitted to Fedora
    remove_multivalue_blanks

    # If entry continues, create a new entry on the next folio and save
    # Also update the current entries 'continues_on' attribute
    next_entry_id = ''
    if params[:commit] == 'Continue'
      is_entry_on_next_folio
      next_entry_id = create_next_entry(@is_entry_on_next_folio)
    end

    # Save form data to Fedora
    @entry.save

    # If entry continues, redirect to the first entry on the next folio
    # Else redirect to the index page
    if next_entry_id != ''
      redirect_to :controller => 'entries', :action => 'edit', :id => next_entry_id
    else
      redirect_to :controller => 'entries', :action => 'index', :id => @entry.id
    end

  end

  # DESTROY
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    redirect_to entries_path, notice: 'Project was successfully destroyed.'
  end

  # PRIVATE METHODS
  private

  # Set entry for the specified id
  def set_entry
    if params[:id] != nil && params[:id] != ''
      @entry = Entry.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def entry_params
    params.require(:entry).permit! # Note - this needs changing because it allows through all params at the moment!!
    #params.require(:entry).permit(:entry_no, :access_provided_by, editorial_notes_attributes: [:id, :editorial_note, :_destroy], people_attributes: [:id, :name_as_written, :note, :age, :gender, :name_authority, :_destroy])
  end

  # Remove multi-value fields which are empty
  # Note that there was an error when submitting a form with no multi-value elements
  # Therefore, instead of just removing elements when the user clicks on the 'remove' icon, the elements are hidden and the value set to ''
  # The code below will then remove the element(s) from Fedora
  # Note also that you have to check that size is greater than 0 because an empty array is passed when the 'edit' button is clicked
  # (i.e. if there are no elements) and we don't want to check if the elements are blank if none exist, otherwise an error will occur
  def remove_multivalue_blanks

    if @entry.language.size > 0
      @entry.language = params[:entry][:language].select { |element| element.present? }
    end

    if @entry.note.size > 0
      @entry.note = params[:entry][:note].select { |element| element.present? }
    end

    if @entry.editorial_note.size > 0
      @entry.editorial_note = params[:entry][:editorial_note].select { |element| element.present? }
    end

    if @entry.marginalia.size > 0
      @entry.marginalia = params[:entry][:marginalia].select { |element| element.present? }
    end

    if @entry.summary.size > 0
      @entry.summary = params[:entry][:summary].select { |element| element.present? }
    end

    if @entry.is_referenced_by.size > 0
      @entry.is_referenced_by = params[:entry][:is_referenced_by].select { |element| element.present? }
    end

    if @entry.subject.size > 0
      @entry.subject = params[:entry][:subject].select { |element| element.present? }
    end

    # Note:
    # Adding blank Place and updating - element is removed and doesn't go into following code - equals [] - why?
    # Adding blank Place, then removing with 'x' icon - don't disappear and goes into the following code
    # However, if exists in Fedora and remove with 'x' then disappears!
    # Note solved the above problem by not passing '_destroy' = '1' if the element was blank but did not exist in Fedora
    @entry.related_places.each_with_index do |related_place, index|
      #puts params.inspect
      #puts params[:entry][:related_place]
      #puts params[:entry][:related_places_attributes][1]
      @entry.related_places[index].place_as_written = related_place.place_as_written.select { |element| element.present? };
      @entry.related_places[index].place_role = related_place.place_role.select { |element| element.present? };
      @entry.related_places[index].place_type = related_place.place_type.select { |element| element.present? };
      @entry.related_places[index].place_note = related_place.place_note.select { |element| element.present? };
      #puts @entry.related_places[index].place_as_written.size;
      #puts @entry.related_places[index].place_as_written;
    end

    @entry.related_people.each_with_index do |related_person, index|
      @entry.related_people[index].person_as_written = related_person.person_as_written.select { |element| element.present? };
      @entry.related_people[index].person_role = related_person.person_role.select { |element| element.present? };
      @entry.related_people[index].person_note = related_person.person_note.select { |element| element.present? };
      @entry.related_people[index].person_related_place = related_person.person_related_place.select { |element| element.present? };
    end
  end

  # Check if session has timed out
  # Note that the session timeout value is set in config/initializers/session_store.rb
  def session_timed_out
    if session[:login] != 'true'
      redirect_to :controller => 'login', :action => 'timed_out'
    end
  end
end
