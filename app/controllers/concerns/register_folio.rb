module RegisterFolio

  # Set the first and last folio session variables - this is used to grey out
  # the '<' and '>' icons if the limits are reached
  def set_first_and_last_folio

    register = Register.find(session[:register_id])
    session[:first_folio_id] = register.ordered_folio_proxies.first.target_id
    session[:last_folio_id] = register.ordered_folio_proxies.last.target_id

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
      SolrQuery.new.solr_query('id:"' + session[:register] + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
        order = result['ordered_targets_ssim']
        # convert the list of folios in order into a hash so we can access the position of our id
        hash = Hash[order.map.with_index.to_a]
        if action == 'next_tesim'
          next_id = order[hash[id] + 1]
        elsif action == 'prev_tesim'
          next_id = order[hash[id] - 1]
        end
      end
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

    next_id = '', next_image = ''

    # Set the browse id
    if action != nil && id != nil
      SolrQuery.new.solr_query('id:"' + session[:register] + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
        order = result['ordered_targets_ssim']
        # convert the list of folios in order into a hash so we can access the position of our id
        hash = Hash[order.map.with_index.to_a]
        if action == 'next_tesim'
          next_id = order[hash[id] + 1]
        elsif action == 'prev_tesim'
          next_id = order[hash[id] - 1]
        end
      end
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

    # Get the list of folios in order
    SolrQuery.new.solr_query('id:"' + register + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
      order = result['ordered_targets_ssim']
      q = ''
      order.each do |o|
        q += 'id:"' + o + '" OR '
      end
      # there is probably a neater way of doing this
      if q.end_with? ' OR '
        q = q[0..q.length - 4]
      end
      SolrQuery.new.solr_query(q, 'id,preflabel_tesim')['response']['docs'].map.each do |res|
        folio_hash[res['id']] = res['preflabel_tesim'].join()
        @folio_list += [res['id'],folio_hash[res['id']]]
      end
    end
  end

  # Determines which message is displayed when the user clicks the 'Continue' button
  def is_entry_on_next_folio

    next_folio_id = ''

    # First get the next_folio_id...
    SolrQuery.new.solr_query('id:"' + session[:register] + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
      order = result['ordered_targets_ssim']
      # convert the list of folios in order into a hash so we can access the position of our id
      hash = Hash[order.map.with_index.to_a]
      next_folio_id = hash[session[:folio_id] + 1]
    end

    @is_entry_on_next_folio = false

    # Then determine if an entry exists
    if next_folio_id != nil
      SolrQuery.new.solr_query('folio_ssim:"' + next_folio_id + '"', 'id', 1)['response']['docs'].map do |result|
        @is_entry_on_next_folio = true
      end
    end

    # Return value
    @is_entry_on_next_folio
  end

  # Determines if the 'Continues on next folio' row and 'Continues' button are to be displayed
  def is_last_entry(entry)
    if entry != nil
      @is_last_entry = false
      max_entry_no = get_max_entry_no_for_folio
      if entry.entry_no.to_i >= max_entry_no.to_i
        @is_last_entry = true
      end
    end
  end

  # Determines if the 'New Entry' Tab and '(continues)' text are to be displayed
  def set_folio_continues_id

    @folio_continues_id = ''

    SolrQuery.new.solr_query('folio_ssim:"' + session[:folio_id] + '"', 'id', 100)['response']['docs'].each do |result|
      entry_id = result['id']
      SolrQuery.new.solr_query('id:"' + entry_id + '"', 'continues_on_tesim,entry_no_tesim', 1)['response']['docs'].each do |result|
        if result['continues_on_tesim'] != nil
          @folio_continues_id = result['entry_no_tesim'].join()
        end
      end
    end

    return @folio_continues_id
  end

  # If the entry is continued onto the next folio, creates the entry and
  # sets the new session variables
  # Also sets the entry 'continues_on' attribute
  # HERE
  def create_next_entry(create_entry_status)

    next_folio_id = ''

    SolrQuery.new.solr_query('id:"' + session[:register] + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
      order = result['ordered_targets_ssim']
      # convert the list of folios in order into a hash so we can access the position of our id
      hash = Hash[order.map.with_index.to_a]
      next_folio_id = hash[session[:folio_id] + 1]
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
  # TODO there will be two collections, get both and combine
  def get_registers_in_order
    # Get the collection so that we can get a list of registers in order
    collection = ''
    SolrQuery.new.solr_query('has_model_ssim:OrderedCollection AND coll_id_tesim:"Abp Reg"', 'id')['response']['docs'].map.each do |result|
      collection = result['id']
    end
    registers = Hash.new
    # Get the ordered list of registers
    SolrQuery.new.solr_query('id:"' + collection + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |result|
      order = result['ordered_targets_ssim']
      q = ''
      order.each do |o|
        q += 'id:"' + o + '" OR '
      end
      # there is probably a neater way of doing this
      if q.end_with? ' OR '
        q = q[0..q.length - 4]
      end
      # run a single query for all registers
      SolrQuery.new.solr_query(q, 'id,preflabel_tesim,reg_id_tesim')['response']['docs'].map.each do |res|
          registers[res['id']] = [res['reg_id_tesim'][0], res['preflabel_tesim'][0]]
      end
    end
    registers
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
      render 'timed_out/timed_out_small', :layout => 'timed_out_small'
    end
  end

  # Used in person / place popus to check that variable is a valid URL
  # Check that same_as is a URL
  def check_url(var_array, error, title)
    if var_array != nil
      var_array.each do |var|
        if var !~ /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
          if error != ''
            error = error + "<br/>"
          end
          error = error + "Please enter a valid  URL for '" + title + "'"
        end
      end
    end
    return error
  end

  # Set the entry tab list (i.e. at the top of the form)
  def set_entry_list

    # This is an array of array ('id' and 'entry_no')
    @entry_list = []

    SolrQuery.new.solr_query(q='has_model_ssim:Entry AND folio_ssim:' + session[:folio_id], fl='id,entry_no_tesim', rows=1000, sort='id asc')['response']['docs'].map.each do |result|
      id = result['id']
      entry_no = result['entry_no_tesim'].join
      temp = []
      temp[0] = id
      temp[1] = entry_no
      @entry_list << temp
    end
  end

  # Update rdf types
  def update_rdf_types
    unless params[:entry][:related_person_groups_attributes].nil?
      params[:entry][:related_person_groups_attributes].each do |key, value|
        value.each do |k, v|
          if k == 'rdftype'
            params[:entry][:related_person_groups_attributes][key][k] = v.gsub!("[", "").gsub!('"', '').gsub!("]", '').gsub(' ', '').split(',').collect { |s| s }
          end
        end
      end
    end
    unless params[:entry][:related_places_attributes].nil?
      params[:entry][:related_places_attributes].each do |key, value|
        value.each do |k, v|
          if k == 'rdftype'
            params[:entry][:related_places_attributes][key][k] = v.gsub!("[", "").gsub!('"', '').gsub!("]", '').gsub(' ', '').split(',').collect { |s| s }
          end
        end
      end
    end
    unless params[:entry][:entry_dates_attributes].nil?
      params[:entry][:entry_dates_attributes].each do |key, value|
        value.each do |k, v|
          if k == 'rdftype'
            params[:entry][:entry_dates_attributes][key][k] = [v.gsub!("[", "").gsub!('"', '').gsub!("]", '').gsub(' ', '')]
          end
          if k == 'single_dates_attributes'
            v.each do |ke, va|
              va.each do |keya, val|
                if keya == 'rdftype'
                  params[:entry][:entry_dates_attributes][key][k][ke][keya] = [val.gsub!("[", "").gsub!('"', '').gsub!("]", '').gsub(' ', '')]
                end
              end
            end
          end
        end
      end
    end
  end

  # This method adds relatedPlaceFor relations to RelatedPersonGroups by looking up the RelatedPlace id for each person_related_place
  def update_related_places
    begin
      q = 'relatedPlaceFor_ssim:"' + @entry.id + '"'
      SolrQuery.new.solr_query(q, 'id,place_as_written_tesim', 50)['response']['docs'].each do |result|
        q = 'relatedAgentFor_ssim:"' + @entry.id + '" AND person_related_place_tesim:"' + result['place_as_written_tesim'][0] + '"'
        begin
          SolrQuery.new.solr_query(q, 'id,person_related_place_tesim', 50)['response']['docs'].each do |res|
            place = RelatedPlace.where(id: result['id']).first
            places = place.related_person_group
            places += [RelatedPersonGroup.where(id: res['id']).first]
            place.related_person_group = places
            place.save
          end
        rescue
          # move along
        end
      end
    rescue
      # move along
    end
  end

  # Return array of folio / entry numbers which contain the specified concept / subject
  def get_existing_location_list(type, element_id)

    existing_location_list = []


    if type == 'entry_type' or type == 'language' or type == 'section_type' or type == 'subject'

      search_term2 = type + '_tesim:' + element_id

      SolrQuery.new.solr_query(q=search_term2, fl='id, folio_ssim, entry_no_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
        folio_id = result['folio_ssim'].join
        entry_no = result['entry_no_tesim'].join
        folio = SolrQuery.new.solr_query(q='id:' + folio_id, fl='preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map.first['preflabel_tesim'].join
        existing_location_list << folio + ' (Entry No = ' + entry_no + ')'
      end
    else

      search_term1 = ''

      if type == 'date_role' then
        search_term1 = 'date_role_tesim'; fl_term = 'entryDateFor_ssim'
      end
      if type == 'descriptor' then
        search_term1 = 'person_descriptor_tesim'; fl_term = 'relatedAgentFor_ssim'
      end
      if type == 'person_role' then
        search_term1 = 'person_role_tesim'; fl_term = 'relatedAgentFor_ssim'
      end
      if type == 'place_role' then
        search_term1 = 'place_role_tesim'; fl_term = 'relatedPlaceFor_ssim'
      end
      if type == 'place_type' then
        search_term1 = 'place_type_tesim'; fl_term = 'relatedPlaceFor_ssim'
      end
      if type == 'person_same_as' then
        search_term1 = 'person_same_as_tesim'; fl_term = 'relatedAgentFor_ssim'
      end
      if type == 'place_same_as' then
        search_term1 = 'place_same_as_tesim'; fl_term = 'relatedPlaceFor_ssim'
      end

      SolrQuery.new.solr_query(q=search_term1 + ':' + element_id, fl=fl_term, rows=1000, sort='id ASC')['response']['docs'].map do |result|
        search_term2 = 'id:' + result[fl_term].join
        SolrQuery.new.solr_query(q=search_term2, fl='id, folio_ssim, entry_no_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
          folio_id = result['folio_ssim'].join
          entry_no = result['entry_no_tesim'].join
          folio = SolrQuery.new.solr_query(q='id:' + folio_id, fl='preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map.first['preflabel_tesim'].join
          existing_location_list << folio + ' (Entry No = ' + entry_no + ')'
        end
      end
    end

    return existing_location_list
  end

  # Returns concept_scheme id for the particular concept
  def get_concept_scheme_id(list_type)
    concept_list_type = "#{list_type.downcase}s"
    concept_list_type = concept_list_type.sub ' ', '_'
    response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:' + concept_list_type, fl='id', rows=1, sort='')
    concept_scheme_id = response['response']['docs'][0]['id']
    return concept_scheme_id
  end

  # Return hash of parent /child ids and labels
  def get_parent_child_list

    parent_child_list = {}
    parent_child_list[@concept.id] = @concept.preflabel

    SolrQuery.new.solr_query(q='broader_tesim:' + @concept.id, fl='id, preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
      id = result['id']
      preflabel = result['preflabel_tesim'].join
      parent_child_list[id] = preflabel
      SolrQuery.new.solr_query(q='broader_tesim:' + id, fl='id, preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
        id2 = result['id']
        preflabel2 = result['preflabel_tesim'].join
        parent_child_list[id2] = preflabel2
      end
    end

    return parent_child_list
  end

end