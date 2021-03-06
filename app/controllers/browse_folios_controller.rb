# frozen_string_literal: true

class BrowseFoliosController < ApplicationController
  before_action :session_timed_out_small

  layout 'browse_folios'

  def index
    begin
      # Do this if the popup link is clicked
      if params[:is_popup] == 'true'
        session[:browse_id] = session[:folio_id]
        session[:browse_image] = session[:folio_image]
      # Else do this if the '<' or '>' buttons are clicked
      elsif !params[:browse_action].nil?
        set_folio_and_image_browse(params[:browse_action], session[:browse_id])
      end
    end
  rescue StandardError => e
    log_error(__method__, __FILE__, e)
    raise
  end
end
