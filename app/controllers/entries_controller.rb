class EntriesController < ApplicationController

  # Set the entry number, get the folio list (for the drop-down) and check if the session is timed out before calling the appropriate methods
  before_action :set_entry, only: [:index, :show, :update]
  #before_action :get_registers, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  #before_action :get_folios, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  #before_filter :session_timed_out, except: [:login]

  # NOTE - we want to display folio with a space or underscore, e.g. 'Insert a' but save the field as 'Inserta' because
  # there was a problem with the 'Entry.where' statement when a space occurred - not sure why

  # INDEX
  def index

    #puts "INDEX (ENTRIES)"
    #puts params

    # Set the appropriate session variables when the register, folio and folio face are chosen and the 'Go' button is clicked
    if params[:set_folio] == 'true'
      set_folio
    elsif params[:set_folio_next_previous] != nil
      set_folio_next_previous(params[:set_folio_next_previous])
    end

    get_folios

    if session[:register_choice] != '' && session[:folio_choice] != ''

      # Get the first entry for the folio if there isn't an id,  else get the entry with the appropriate id
      if params[:id] == nil || params[:id] == ''
        @entry = Entry.where(folio_ssim: session[:folio_choice]).first
      else
        @entry = Entry.find(params[:id])
      end

      # Get all the entries which match with the chosen register, folio and folio face
      @entries = Entry.where(folio_ssim: session[:folio_choice])

      #set_entry
    end

  end

  # SHOW
  # This is called when the user clicks on the 'Go' button
  def show

    @entries = Entry.all.where(folio_ssim: session[:folio_choice])

    redirect_to :action => 'index', :id => params[:id]

  end

  # NEW
  def new

    # This code sets the new session variables and redirects to index if the 'Go' button is clicked on the new page
    if params[:go] == 'true'
      get_current_folio
      redirect_to :action => 'index'
    end

    @entry = Entry.new

    @entries = Entry.where(folio_ssim: session[:folio_choice])
    get_authority_lists

    get_folios

  end

  # EDIT
  def edit

    # This code sets the new session variables and redirects to index if the 'Go' button is clicked on the edit page
    if params[:go] == 'true'
      get_current_folio
      redirect_to :action => 'index'
    end

    # Get all the entries so that they can be displayed as tabs
    @entries = Entry.all.where(folio_ssim: session[:folio_choice])

    # Get the fields for the current entry
    set_entry
    #puts @entry.inspect

    # Set the authroity lists
    get_authority_lists

    # Define the related person list
    # # Note that this is a dynamic list which has to be initialised
    # before editing the page so that the form displays the correct values
    @related_place_list = []

    # Add default select option to the related place list
    temp = []
    temp << '--- select ---'
    temp << ''
    @related_place_list << temp

    # Add other elements to the related place list, i.e. using 'RelatedPlace' -> 'place_as_written'
    @entry.related_places.each do |related_place|
      temp = []
      if related_place.place_as_written.count > 0
        temp << related_place.place_as_written[0] # Only use the first 'place_as_written for the list
        @related_place_list << temp
      end
    end

    get_folios

  end

  # CREATE
  def create

    # See validation.rb in /concerns
    #@errors = validate(entry_params)

    # Get a new entry and replace values with the form parameters
    # Replace the folio id with the corresponding Folio object
    f = Folio.where(id: entry_params['folio']).first
    entry_params['folio'] = f
    @entry = Entry.new(entry_params)

    # If there are errors, go back to the 'new' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil
      @entries = Entry.where(folio_ssim: session[:folio_choice])
      get_authority_lists
      render 'new'
    else
      # Remove multi-value fields which are empty
      @entry.save
      redirect_to :action => 'index', :id => @entry.id
    end
  end

  # UPDATE
  def update

    # See validation.rb in /concerns
    #@errors = validate(entry_params)

    # Replace the folio id with the corresponding Folio object
    f = Folio.where(id: entry_params['folio']).first
    entry_params['folio'] = f

    @entry.attributes = entry_params

    # If there are errors, render the go back to the 'edit' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil
      @entries = Entry.where(folio_ssim: session[:folio_choice])
      get_authority_lists
      #@entry.attributes = entry_params # Updates the @entry with the appropriate attributes before rendering the 'edit' page
      set_entry
      get_folios()
      render 'edit'
    else

      # Remove any multivalue blank fields or they will be submitted to Fedora
      remove_multivalue_blanks

# This code might be used later on
=begin
if entry_params[:related_people_attributes] != nil
  entry_params[:related_people_attributes].values.each do |related_person|
    related_person_id = related_person[:id]
    person_related_place = related_person[:person_related_place]
    puts "Person #{related_person_id}, #{person_related_place}"
    entry_params[:related_places_attributes].values.each do |related_place|
      related_place_id = related_place[:id]
      place_as_written = related_place[:place_as_written]
      puts "   Place #{related_place_id}, #{place_as_written}"
    end
  end
end
=end

      # Save the for data to Fedora
      @entry.save

      # Redirect to the index page and pass the current entry id
      redirect_to :action => 'index', :id => @entry.id

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

  # Get the entry for the specified id
  def set_entry
    if params[:id] != nil && params[:id] != ''
      @entry = Entry.find(params[:id])
      #puts @entry.inspect
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
end
