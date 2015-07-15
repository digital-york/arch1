module RegisterFolio

  # Set the first and last folio session variables - this is used to grey out
  # the '<' and '>' icons if the limits are reached
  def set_first_and_last_folio

    SolrQuery.new.solr_query('id:"' + session[:register_id] + '"', 'fst_tesim', 1)['response']['docs'].map do |result|
      session[:first_folio_id] = result['fst_tesim'][0]
    end

    SolrQuery.new.solr_query('id:"' + session[:register_id] + '"', 'lst_tesim', 1)['response']['docs'].map do |result|
      session[:last_folio_id] = result['lst_tesim'][0]
    end
  end

  # Set the folio and image session variables when the user selects an option from the drop-down list
  def set_folio_and_image_drop_down

    folio_id = params[:folio_id].strip

    session[:folio_id] = folio_id

    if folio_id == ''
      session[:folio_image] = ''
    else
      SolrQuery.new.solr_query('hasTarget_ssim:"' + session[:folio_id] + '"', 'file_tesim', 1)['response']['docs'].map do |result|
        session[:folio_image] = result['file_tesim'][0]
      end
    end
  end

  # Set the folio and image session variables, e.g. when the '>' or '<' buttons are clicked
  # action = 'prev_tesim' or 'next_tesim'
  def set_folio_and_image(action, id)

    next_id = ''
    next_image = ''

    # Set the folio id session variable
    SolrQuery.new.solr_query('proxyFor_ssim:"' + id + '"', action, 1)['response']['docs'].map do |result|
      next_id = result[action][0]
    end

    # Set the folio image session variable
    SolrQuery.new.solr_query('hasTarget_ssim:"' + next_id + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      next_image = result['file_tesim'][0]
    end

    session[:folio_id] = next_id
    session[:folio_image] = next_image
 end

  # Set the next (or previous) folio and image session variables (when the '>' or '<' buttons are clicked)
  # action = 'prev_tesim' or 'next_tesim'
  def set_folio_and_image_browse(action, id)

    next_id = ''
    next_image = ''

    # Set the browse id
    SolrQuery.new.solr_query('proxyFor_ssim:"' + id + '"', action, 1)['response']['docs'].map do |result|
      next_id = result[action][0]
    end

    # Set the browse image
    SolrQuery.new.solr_query('hasTarget_ssim:"' + next_id + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      next_image = result['file_tesim'][0]
    end

    session[:browse_id] = next_id
    session[:browse_image] = next_image
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

  # Does an entry exist for the next folio?
  def is_entry_on_next_folio

    next_folio_id = ''

    # First get the next_folio_id...
    SolrQuery.new.solr_query('proxyFor_ssim:"' + session[:folio_id] + '"', 'next_tesim', 1)['response']['docs'].map do |result|
      next_folio_id = result['next_tesim'][0]
    end

    @is_entry_on_next_folio = false

    # ...then determine if an entry exists
    if next_folio_id != nil
      SolrQuery.new.solr_query('folio_ssim:"' + next_folio_id + '"', 'id', 1)['response']['docs'].map do |result|
        @is_entry_on_next_folio = true
      end
    end

    # Return
    @is_entry_on_next_folio
  end

  def is_last_entry(entry)
    if entry != nil
      @is_last_entry = false
      max_entry_no = get_max_entry_no_for_folio
      if entry.entry_no.to_i >= max_entry_no.to_i
        @is_last_entry = true
      end
    end
  end

  # Does the folio contain an entry which continues?
  # (this determines if the 'New Entry' Tab and '(continues)' text are displayed)
  def set_folio_continues_id

    @folio_continues_id = ''

    SolrQuery.new.solr_query('folio_ssim:"' + session[:folio_id] + '"', 'id', 100)['response']['docs'].each do |result|
      entry_id = result['id']
      SolrQuery.new.solr_query('id:"' + entry_id + '"', 'continues_on_tesim, entry_no_tesim', 1)['response']['docs'].each do |result|
        if result['continues_on_tesim'] != nil
          @folio_continues_id = result['entry_no_tesim']
          @folio_continues_id = @folio_continues_id.join('')
        end
      end
    end

    # Return
    @folio_continues_id
  end

  # If the entry is continued onto the next folio, creates the entry and
  # sets the new session variables
  # Also sets the entry 'continues_on' attribute
  def create_next_entry(create_entry_status)

      next_folio_id = ''

      SolrQuery.new.solr_query('proxyFor_ssim:"' + @entry.folio_id + '"', 'next_tesim', 1)['response']['docs'].map do |result|
        next_folio_id = result['next_tesim'][0]
      end

      # Only create a new entry if one doesn't already exist on the next folio
      if @is_entry_on_next_folio == false
        new_entry = Entry.new
        new_entry.entry_no = '1'
        new_entry.folio_id = next_folio_id
        new_entry.save
      end

      # Add the next folio id to the entry
      @entry.continues_on = next_folio_id

      # Set the next folio_id and folio_image session variables
      set_folio_and_image('next_tesim', session[:folio_id])


      # Return the new id if an entry has been created
      # Else return the first entry id of the next folio
      if @is_entry_on_next_folio == false
        return new_entry.id
      else
        id = ''
        SolrQuery.new.solr_query('folio_ssim:"' + next_folio_id + '"', 'entry_no_tesim, id', 1)['response']['docs'].map do |result|
          id = result['id']
        end
        return id
      end
  end

  # Get the max entry no for the folio
  # i.e used to automate the entry no when adding a new entry
  def get_max_entry_no_for_folio

    max_entry_no = 0

    SolrQuery.new.solr_query('folio_ssim:"' + session[:folio_id] + '"', 'entry_no_tesim', 100)['response']['docs'].each do |result|
      entry_no = result['entry_no_tesim'].join('').to_i
      if entry_no > max_entry_no
        max_entry_no = entry_no
      end
    end

    # return max_entry_no
    max_entry_no
  end

end