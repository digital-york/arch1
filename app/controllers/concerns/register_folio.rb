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

    if action != nil && id != nil

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

    folio_hash = {}

    # Populate the folio_hash with folio_id => preflabel_tesim - this is used to get the title for each id later on
    q = SolrQuery.new.solr_query('has_model_ssim:Folio AND isPartOf_ssim:' + register, 'id, preflabel_tesim', 5000, 'id ASC')

    q['response']['docs'].each do |result|
      folio_id = result['id']
      preflabel_tesim = result['preflabel_tesim'].join()
      # Added [a-z] because some folios have a number like '1a' - might need to alter this later on if other folios do not follow this pattern
      folio_hash[folio_id] = preflabel_tesim.gsub(/Abp Reg \d+[a-z]* /, '')
    end

    proxy_hash = {}

    q = SolrQuery.new.solr_query('has_model_ssim:Proxy AND proxyIn_ssim:' + register, 'next_tesim, prev_tesim, proxyFor_ssim', 5000, 'id ASC')

    next_tesim_start = ''
    proxy_for_ssim_start = ''

    # Populate the proxy_hash with proxy_for_ssim => next_tesim
    q['response']['docs'].each do |result|

      next_tesim = result['next_tesim']
      prev_tesim = result['prev_tesim']
      proxy_for_ssim = result['proxyFor_ssim'].join()

      if next_tesim == nil || next_tesim == ''
        next_tesim = ''
      else
        next_tesim = next_tesim.join()
      end

      # If it is the first object, do not add it to the proxy_hash but store the start values for later on
      if prev_tesim == nil || prev_tesim == ''
        next_tesim_start = next_tesim
        proxy_for_ssim_start = proxy_for_ssim
      else
        proxy_hash[proxy_for_ssim] = next_tesim
      end

    end

    # Add the first object to the folio list
    @folio_list += [[proxy_for_ssim_start, folio_hash[proxy_for_ssim_start]]]

    # Initialise next_tesim
    next_tesim = next_tesim_start

    # Use next_tesim to find each object in turn and add them the folio_list
    # Repeat until there isn't a next_tesim (i.e. the last object)
    until next_tesim == nil || next_tesim == ''
      @folio_list += [[next_tesim, folio_hash[next_tesim]]]
      next_tesim = proxy_hash[next_tesim]
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

    # Return value
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
      SolrQuery.new.solr_query('id:"' + entry_id + '"', 'continues_on_tesim,entry_no_tesim', 1)['response']['docs'].each do |result|
        if result['continues_on_tesim'] != nil

          @folio_continues_id = result['entry_no_tesim']
          @folio_continues_id = @folio_continues_id.join('')
        end
      end
    end

    # Return value
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
        new_entry.entry_type = ''
        new_entry.continues_on = ''
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

    # Return max_entry_no
    max_entry_no
  end

  # Return list of registers (fedora id, register id and title), in order
  def get_registers_in_order

    collection = ''
    first_register = ''

    # Get the collection so that we can get a list of registers and the first register in the sequence
    SolrQuery.new.solr_query('has_model_ssim:OrderedCollection AND coll_id_tesim:"Abp Reg"','id,fst_tesim')['response']['docs'].map.each do | result |
      collection = result['id']
      first_register = result['fst_tesim']
    end

    registers = Hash.new
    num = 0

    # Get the number of registers and the register ids and names
    SolrQuery.new.solr_query('isPartOf_ssim:"' + collection + '"','id,preflabel_tesim,reg_id_tesim')['response'].each do | result |
      if result[0] == 'numFound'
        num = result[1]
      elsif result[0] == 'docs'
        result[1].each do | res |
          registers[res['id']] = [res['reg_id_tesim'][0],res['preflabel_tesim'][0]]
        end
      end
    end

    order = Hash.new
    next_un = ''

    # Order the registers
    for i in 1..num.to_i
      case i
        when 1
          order[first_register[0]] = registers[first_register[0]]
          next_un = SolrQuery.new.solr_query('proxyFor_ssim:"' + first_register[0] + '"','next_tesim')['response']['docs'].map.first['next_tesim']
          order[next_un[0]] = registers[next_un[0]]
        when 9
          # we don't need to process the last one
        else
          next_un = SolrQuery.new.solr_query('proxyFor_ssim:"' + next_un[0] + '"','next_tesim')['response']['docs'].map.first['next_tesim']
          order[next_un[0]] = registers[next_un[0]]
      end
    end
    order
  end

  # This displays the timed out message for the main page
  def session_timed_out
    if session[:login] == '' || session[:login] == nil
      render 'timed_out/timed_out', :layout => 'timed_out'
    end
  end

  # This displays the timed out message for the browse folios, subject popup, person popup and place popup pages
  def session_timed_out_small
    if session[:login] == '' || session[:login] == nil
      render 'timed_out/timed_out_small', :layout => 'timed_out'
    end
  end

end