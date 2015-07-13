class LandingPageController < ApplicationController

  before_filter :session_timed_out

  def index
  end

  def go_entries

    session[:register_id] = params[:register_id]
    session[:register_name] = params[:register_name]

    # This is required for the image '<' and '>' buttons
    get_first_and_last_folio

    redirect_to :controller => 'entries', :action => 'index',  :login_submit => 'true'

  end

  # Check if webapp has timed out
  # Note that the session timeout value is set in config/initializers/session_store.rb
  def session_timed_out
    if session[:login] != 'true'
      redirect_to :controller => 'login', :action => 'timed_out'
    end
  end

end