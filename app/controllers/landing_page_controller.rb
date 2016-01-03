class LandingPageController < ApplicationController

  include RegisterFolioHelper

  before_filter :session_timed_out

  def index

    begin

      set_authority_lists

      # Get register list (in order)
      @reg_list = get_registers_in_order

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  def go_entries

    begin

      reset_session_variables

      session[:register_id] = params[:register_id]
      session[:register_name] = params[:register_name]

      # This is required for the image '<' and '>' buttons
      set_first_and_last_folio

      redirect_to :controller => 'entries', :action => 'index', :login_submit => 'true'

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  def reset_session_variables
    session[:folio_id] = ''
    session[:folio_image] = ''
    session[:first_folio_id] = ''
    session[:last_folio_id] = ''
    session[:browse_id] = ''
    session[:browse_image] = ''
  end

end