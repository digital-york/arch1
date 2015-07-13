module RegisterFolio

  # Get the first and last folio in the folio list and store as session variables so that the image
  # buttons are greyed out if the folio is equal to the first or last image
  def get_first_and_last_folio

    SolrQuery.new.solr_query('id:"' + session[:register_id] + '"', 'fst_tesim', 1)['response']['docs'].map do |result|
      session[:first_folio] = result['fst_tesim'][0]
    end

    SolrQuery.new.solr_query('id:"' + session[:register_id] + '"', 'lst_tesim', 1)['response']['docs'].map do |result|
      session[:last_folio] = result['lst_tesim'][0]
    end

  end

  # Set the folio and image session variables when the user selects an option from the drop-down list
  def set_folio

    session[:folio_id] = params[:folio_id].strip

    SolrQuery.new.solr_query('hasTarget_ssim:"' + session[:folio_id] + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      session[:folio_image] = result['file_tesim'][0]
    end

    # Not sure if we need folio_title anymore because it is not displayed in the small image title - instead there is the drop-down list
    #SolrQuery.new.solr_query('id:"' + session[:folio_id] + '"' , 'title_tesim', 1)['response']['docs'].map do |result|
    #  session[:folio_title] = result['title_tesim'][0]
    #end

  end

  # Set the next (or previous) folio and image session variables (when the '>' or '<' buttons are clicked)
  # Note: action = [prev_tesim|next_tesim]
  def set_small_zoom_folio_and_image(small_zoom_action, small_zoom_id)

    # Set the small_zoom id
    SolrQuery.new.solr_query('proxyFor_ssim:"' + small_zoom_id + '"', small_zoom_action, 1)['response']['docs'].map do |result|
      session[:folio_id] = result[small_zoom_action][0]
    end

    # Set the small zoom image
    SolrQuery.new.solr_query('hasTarget_ssim:"' + small_zoom_id + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      session[:folio_image] = result['file_tesim'][0]
    end

  end

  # Set the next (or previous) folio and image session variables (when the '>' or '<' buttons are clicked)
  # Note: action = [prev_tesim|next_tesim]
  def set_browse_folio_and_image(browse_action, browse_id)

    # Set the browse id
    SolrQuery.new.solr_query('proxyFor_ssim:"' + browse_id + '"', browse_action, 1)['response']['docs'].map do |result|
      session[:browse_id] = result[browse_action][0]
    end

    # Set the browse image
    SolrQuery.new.solr_query('hasTarget_ssim:"' + browse_id + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      session[:browse_image] = result['file_tesim'][0]
    end

  end

  # Set @folio_list - this is used to display the folio drop-down list
  def set_folio_list

    register = session[:register_id]

    @folio_list = []

    q = SolrQuery.new.solr_query('has_model_ssim:"Folio" AND isPartOf_ssim:"' + register + '"', 'id, title_tesim, folio_type_tesim, folio_no_tesim, folio_face_tesim', 1000, 'id ASC')

    # Iterate over the titles and remove the register par - e.g. 'Abp Reg 12 '
    q['response']['docs'].each do |result|
      folio_title = result['title_tesim'].join('')
      folio_title = folio_title.gsub(/Abp Reg \d+ /, "")
      @folio_list += [[result['id'], folio_title]]
    end

  end

end