class EntriesController < ApplicationController

  before_action :set_entry, only: [:index, :show, :edit, :update]
  before_action :get_folios, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_filter :session_timed_out, except: [:login]

  # NOTE - want to display folio with a space, e.g. 'Insert a' but save the field as 'Insert_a' because
  # there was a problem with the 'Entry.where' statement when a space occurred - not sure why

  def session_timed_out
    if session[:login] == '' || session[:login] == nil
      render 'timed_out', :layout => 'session_timed_out'
    end
  end

  def timed_out
    # hopefully render the timed_out page
  end

  # LOGOUT
  def logout
    session[:register_choice] = ''
    session[:folio_choice] = ''
    session[:folio] = ''
    session[:folio_face] = ''
    session[:login] = ''
    redirect_to login_path, :layout => 'login'
  end

  # LOGIN
  def login
    if params[:submit] == 'true'

      if params[:username] == 'test' && params[:password] == 'test'
        session[:login] = 'true'
        redirect_to :action => 'index'
      else
        @error = 'true'
        render :layout => 'login'
      end
    else
      session[:register_choice] = ''
      session[:folio_choice] = ''
      session[:folio] = ''
      session[:folio_face] = ''
      session[:login] = ''
      get_first_and_last_folio
      render :layout => 'login'
    end
  end

  # INDEX
  def index
    
	puts "INDEX"
	
    # Set the appropriate session variables when the register, folio and side are chosen and the 'Go' button is clicked
    if params[:go] == 'true'
      get_folio
    end

    if session[:register_choice] != '' && session[:folio_choice] != ''

      # Get the next folio if the '<' or '>' buttons are clicked
      if params[:change_folio] != nil
        get_next_image(params[:change_folio])
      end

      # Get the first entry for the folio, else get the entry with the appropriate id
      if params[:id] == nil || params[:id] == ''
        @entry = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face]).first
      else
        @entry = Entry.find(params[:id])
      end

      # Get all the entries which match with the chosen register, folio and face
      # NOTE - had real problems with above command when there is a space in the 'folio_face', e.g. 'Insert a', therefore saving with an underscore
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

    # This code gets the new session variables and redirects to index if the 'Go' button is clicked
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
  
    # This code gets the new session variables and redirects to index if the 'Go' button is clicked
    if params[:go] == 'true'
      get_folio
      redirect_to :action => 'index'
    end
	
    @entries = Entry.all.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
    get_authority_lists
  end

  # CREATE
  def create

    puts "CREATE"
	puts "1"
    puts entry_params
	@errors = validate(entry_params)
	puts "2"
	puts entry_params
	
    @entry = Entry.new(entry_params)

	if @errors != '' && @errors != nil
	  @entries = Entry.where(:folio => session[:folio]).where(:folio_face => session[:folio_face])
      get_authority_lists
	  render 'new'
	else @entry.save
      redirect_to :action => 'index', :id => @entry.id
    end
  end

  # UPDATE
  def update
  
    puts "UPDATE"
    puts entry_params
  
    @errors = validate(entry_params)
    
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
	redirect_to entries_path,  notice: 'Project was successfully destroyed.'
  end

  # PRIVATE
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_entry
    if params[:id] != nil && params[:id] != ''
      @entry = Entry.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def entry_params
    params.require(:entry).permit!
    #params.require(:entry).permit(:entry_no, :access_provided_by, editorial_notes_attributes: [:id, :editorial_note, :_destroy], people_attributes: [:id, :name_as_written, :note, :age, :gender, :name_authority, :_destroy])
  end
    
end
