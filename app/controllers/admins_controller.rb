class AdminsController < ApplicationController

  before_filter :session_timed_out_small

  # Reset concept session variables
  def index
    session[:list_type] = ''
    session[:search_term] = ''
    session[:person_field] = nil
    session[:place_field] = nil
  end

end