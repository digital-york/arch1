class LandingPageController < ApplicationController

  before_filter :session_timed_out

  def index
    set_authority_lists
    # Get register list (in order)
    @reg_list = get_registers_in_order
    # Code which associates reg_id_tesim with ids (for the landing page) - will probably be modified when registers are ordered
    # The reg_id values in the array below are matched with those from the solr query and then the ids are put into the @reg_id_list
    # Also sets the image file names and register titles
    # @reg_id_tesim_list = ['Abp Reg 1A', 'Abp Reg 1B', 'Abp Reg 03', 'Abp Reg 08', 'Abp Reg 12', 'Abp Reg 22', 'Abp Reg 23', 'Abp Reg 26', 'Abp Reg 28']
    # len = @reg_id_tesim_list.length
    # @reg_id_list = Array.new(len)
    # @reg_title_list = Array.new(len)
    # @reg_image_list = Array.new(len)
    #
    # SolrQuery.new.solr_query('has_model_ssim:Register', 'id, reg_id_tesim, preflabel_tesim', 20)['response']['docs'].map do |result|
    #   id = result['id']
    #   reg_id_tesim = result['reg_id_tesim'][0]
    #   preflabel_tesim = result['preflabel_tesim'][0]
    #   @reg_id_tesim_list.each_with_index do |title, index|
    #     if title.match(reg_id_tesim)
    #       @reg_id_list[index] = id
    #       @reg_title_list[index] = preflabel_tesim.strip
    #       @reg_image_list[index] = title.gsub(/Abp Reg /, 'reg_') + '.png'
    #       break
    #     end
    #   end
    # end
 end

  def go_entries

    reset_session_variables

    session[:register_id] = params[:register_id]
    session[:register_name] = params[:register_name]

    # This is required for the image '<' and '>' buttons
    set_first_and_last_folio

    redirect_to :controller => 'entries', :action => 'index',  :login_submit => 'true'
  end

  def reset_session_variables
    session[:folio_id] = ''
    session[:folio_image] = ''
    session[:first_folio_id] = ''
    session[:last_folio_id] = ''
    session[:browse_id] = ''
    session[:browse_image] = ''
  end

  # Check if webapp has timed out
  # Note that the session timeout value is set in config/initializers/session_store.rb
  def session_timed_out
    if session[:login] != 'true'
      redirect_to :controller => 'login', :action => 'timed_out'
    end
  end

end