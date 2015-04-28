class EntriesController < ApplicationController

  # Set the entry number, get the folio list (for the drop-down) and check if the session is timed out before calling the appropriate methods
  before_action :set_entry, only: [:index, :show, :edit, :update]
  before_action :get_folios, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_filter :session_timed_out, except: [:login]

  # NOTE - want to display folio with a space, e.g. 'Insert a' but save the field as 'Insert_a' because
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
    session[:register_choice] = ''
    session[:folio_choice] = ''
    session[:folio] = ''
    session[:folio_face] = ''
    session[:login] = ''
    session[:first_folio] = ''
    session[:last_folio] = ''
    redirect_to login_path, :layout => 'login'
  end

  # LOGIN
  def login

    # If request is from the login page do this...
    if params[:submit] == 'true'

      # Simple test for username/password (hard-coded - this will be changed to proper authorisation later on)
      if params[:username] == 'test' && params[:password] == 'test'
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
      get_folio
    end

    if session[:register_choice] != '' && session[:folio_choice] != ''

      # Get the next folio if the '<' or '>' buttons are clicked
      if params[:button_action] != nil
        get_next_image(params[:button_action])
      end

      # Get the first entry for the folio if there isn't an id, else get the entry with the appropriate id
      if params[:id] == nil || params[:id] == ''
        @entry = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face]).first
        # NOTE - had real problems with the above when there was a space in the 'folio_face', e.g. 'Insert a'; therefore saving to Fedora with an underscore
      else
        @entry = Entry.find(params[:id])
      end

      # Get all the entries which match with the chosen register, folio and folio face
      @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
    end
  end

  # SHOW
  def show
    @entries = Entry.all.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
    redirect_to :action => 'index', :id => params[:id]
  end

  # NEW
  def new

    # This code sets the new session variables and redirects to index if the 'Go' button is clicked on the new page
    if params[:go] == 'true'
      get_folio
      redirect_to :action => 'index'
    end

    @entry = Entry.new
    @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
    get_authority_lists
  end

  # EDIT
  def edit

    # This code sets the new session variables and redirects to index if the 'Go' button is clicked on the edit page
    if params[:go] == 'true'
      get_folio
      redirect_to :action => 'index'
    end

    @entries = Entry.all.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
    get_authority_lists
  end

  # CREATE
  def create

    # See validation.rb in /concerns
    @errors = validate(entry_params)

    # Get a new entry and replace values with the form parameters
    @entry = Entry.new(entry_params)

    # If there are errors, go back to the 'new' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil
      @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
      get_authority_lists
      render 'new'
    else
      @entry.save
      redirect_to :action => 'index', :id => @entry.id
    end
  end

  # UPDATE
  def update

    # See validation.rb in /concerns
    @errors = validate(entry_params)

    # If there are errors, render the go back to the 'edit' page and display the errors, else go to the 'index' page
    if @errors != '' && @errors != nil
      @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
      get_authority_lists
      @entry.attributes = entry_params # Updates the @entry with the appropriate attributes before rendering the 'edit' page
      render 'edit'
    else
      @entry.update(entry_params)
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

end
