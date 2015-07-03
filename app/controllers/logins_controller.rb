class LoginsController < ApplicationController

  def landing_page
    #puts 'login#landing_page'
  end

  # LOGIN
  def index
    #puts 'login#index'
  end

# LOGIN
  def login_submit

    #puts 'login#submit'

    # If request is from the login page do this...
    if params[:submit] == 'true'

      # Simple test for username/password (hard-coded - this will be changed to proper authorisation later on)
      #if params[:username] == 'test' && params[:password] == 'test'
      if params[:submit] == 'true'

        # Reset all the session variables at this point
        reset_session_variables

        # This is the session login token which we can test in the 'before_filter' method at the top of the entries controller
        session[:logins] = 'true'
        session[:register_choice] = params[:register_choice]
        session[:register_name] = params[:register_name]

        # This is required for the image '<' and '>' buttons
        get_first_and_last_folio

        redirect_to :controller => 'entries', :action => 'index',  :login_submit => 'true'

      else
        @error = 'true'
        redirect_to login_path
      end

    # Else request has come from the session timeout page so do this...
    else
      redirect_to login_path
    end

  end

  def reset_session_variables
    session[:register_choice] = ''
    session[:folio_choice] = ''
    session[:logins] = ''
    session[:first_folio] = ''
    session[:last_folio] = ''
  end

# Check the :login variable in the session to see if the session has timed out
# If so, render 'timed_out.erb'
# Note that the session timeout value is set in config/initializers/session_store.rb
  def session_timed_out
    if session[:logins] == '' || session[:logins] == nil
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

  #def login
  #  @login = Login.new
  #end

  #def create
  #  @login = Login.new(login_params)
  #  if params[:username] == 'test' && params[:password] == 'test'
  #    redirect_to :controller => 'entry', :action => 'login'
  #  else
  #    @error = 'incorrect_login'
  #    redirect_to :action => 'login'
  #  end
  #end

end