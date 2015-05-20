class EntriesController < ApplicationController

  # Set the entry number, get the folio list (for the drop-down) and check if the session is timed out before calling the appropriate methods
  before_action :set_entry, only: [:index, :show, :update]
  before_action :get_folios, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_filter :session_timed_out, except: [:login]

  # NOTE - we want to display folio with a space or underscore, e.g. 'Insert a' but save the field as 'Inserta' because
  # there was a problem with the 'Entry.where' statement when a space occurred - not sure why

  # Check the :login variable in the session to see if the session has timed out
  # If so, render 'timed_out.erb'
  # Note that the session timeout value is set in config/initializers/session_store.rb
  def session_timed_out
    if session[:login] == '' || session[:login] == nil
      render 'timed_out', :layout => 'session_timed_out'
    end
  end

  def timed_out
    # Hopefully render the timed_out page (see render 'timed_out' above)
  end

  # LOGOUT
  # Make sure the session variables are all made equal to '' and redirect to the login page
  def logout
    reset_session_variables
    redirect_to root_path, :layout => 'login'
  end

  def reset_session_variables
    session[:register_choice] = ''
    session[:folio_choice] = ''
    session[:folio] = ''
    session[:folio_face] = ''
    session[:login] = ''
    session[:first_folio] = ''
    session[:last_folio] = ''
  end

  # LOGIN
  def login

    # If request is from the login page do this...
    if params[:submit] == 'true'

      # Simple test for username/password (hard-coded - this will be changed to proper authorisation later on)
      if params[:username] == 'test' && params[:password] == 'test'
        reset_session_variables # Reset the session variables first
        session[:login] = 'true' # This is the session login token which we can test in the 'before_filter' method at the top
        get_first_and_last_folio # This is needed for the image '<' and '>' buttons
        redirect_to :action => 'index'
      else
        @error = 'true'
        render :layout => 'login'
      end
      # Else request has come from the session timeout page so do this...
    else
      render :layout => 'login'
    end
  end

  # INDEX
  def index

    # Set the appropriate session variables when the register, folio and folio face are chosen and the 'Go' button is clicked
    if params[:go] == 'true'
      get_current_folio
    end

    if session[:register_choice] != '' && session[:folio_choice] != ''

      # Get the next folio if the '<' or '>' buttons are clicked
      if params[:button_action] != nil
        get_next_image(params[:button_action])
      end

      # Get the first entry for the folio if there isn't an id, else get the entry with the appropriate id
      if params[:id] == nil || params[:id] == ''
        # NOTE - the command below returns an error when there is a space in the 'folio_face', e.g. 'Insert a'; therefore saving to Fedora with an underscore
        # UPDATE - have had a problem with underscores on the opal server - e.g. 'Insert_a' returns an error but 'Insert_b' works - not sure what is going on here!
        # Anyway, now saved without any char in-between, e.g. 'Inserta'
        @entry = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face]).first
      else
        @entry = Entry.find(params[:id])
      end

      # Get all the entries which match with the chosen register, folio and folio face
      @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])

      set_entry
    end
  end

  # SHOW
  def show
    @entries = Entry.all.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
    redirect_to :action => 'index', :id => params[:id]

    set_entry
  end

  # NEW
  def new

    # This code sets the new session variables and redirects to index if the 'Go' button is clicked on the new page
    if params[:go] == 'true'
      get_current_folio
      redirect_to :action => 'index'
    end

    @entry = Entry.new
    #add_blank_fields_to_array

    @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])

    get_authority_lists

  end

  # EDIT
  def edit

    # This code sets the new session variables and redirects to index if the 'Go' button is clicked on the edit page
    if params[:go] == 'true'
      get_current_folio
      redirect_to :action => 'index'
    end

    @entries = Entry.all.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
    get_authority_lists

    set_entry

  end

  # CREATE
  def create

    # See validation.rb in /concerns
    #@errors = validate(entry_params)

    # Get a new entry and replace values with the form parameters
    @entry = Entry.new(entry_params)

    # If there are errors, go back to the 'new' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil
      @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
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
    @entry.attributes = entry_params

    # If there are errors, render the go back to the 'edit' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil
      @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
      get_authority_lists
      #@entry.attributes = entry_params # Updates the @entry with the appropriate attributes before rendering the 'edit' page
      set_entry
      render 'edit'
    else
      remove_multivalue_blanks
      @entry.save
      set_entry
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
  # (i.e. if there are no elements) and we don't want to check if the elements are blank if none exist, otherwise an error occurs
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

    if @entry.marginal_note.size > 0
      @entry.marginal_note = params[:entry][:marginal_note].select { |element| element.present? }
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
      @entry.related_places[index].place_type = related_place.place_type.select { |element| element.present? };
      @entry.related_places[index].place_note = related_place.place_note.select { |element| element.present? };
      #puts @entry.related_places[index].place_as_written.size;
      #puts @entry.related_places[index].place_as_written;
    end
  end
end
