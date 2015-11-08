class LoginController < ApplicationController

  def index
  end

  def login_submit

    # Proper authorisation will be added later on
    username = params[:username]
    password = params[:password]

    if (username == 'allinson' or username == 'watt' or username =='young') && password == 'iteotwawki'

        # Reset all the session variables at this point
        reset_session_variables

        # This is the session login token which we can test in the 'before_filter' method at the top of the entries controller
        session[:login] = 'true'

        redirect_to :controller => 'landing_page', :action => 'index'

    # Else request has come from the session timeout page so do this...
    else
      @invalid_login = 'true'
      render 'index'
    end
  end

  # Temporary code to bypass the login page
  def login_temp
    reset_session_variables
    session[:login] = 'true'
    redirect_to :controller => 'landing_page', :action => 'index'
  end

  def reset_session_variables
    session[:login] = ''
    session[:register_id] = ''
    session[:register_name] = ''
    session[:folio_id] = ''
    session[:folio_image] = ''
    session[:first_folio_id] = ''
    session[:last_folio_id] = ''
    session[:browse_id] = ''
    session[:browse_image] = ''
  end

  # Make sure the session variables are all reset and redirect to the login page
  def logout
    reset_session_variables
    redirect_to root_path, :layout => 'login'
  end

  def timed_out
  end

end