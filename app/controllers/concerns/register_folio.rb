module RegisterFolio

  # Get the list of folios for a register
  # This is called repeated times; it would be nice to call once per register
  def set_order

    begin
      @order = SolrQuery.new.solr_query('id:"' + session[:register_id] + '/list_source"', 'ordered_targets_ssim', 1)['response']['docs'][0]['ordered_targets_ssim']
    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Set the first and last folio session variables - this is used to grey out
  # the '<' and '>' icons if the limits are reached
  def set_first_and_last_folio

    begin
      set_order
      session[:first_folio_id] = @order[0]
      session[:last_folio_id] = @order[@order.length-1]
        # Timings indicate that this step for 5A (the longest register) took 26s; the new code took 4s
        #register = Register.find(session[:register_id])
        #session[:first_folio_id] = register.ordered_folio_proxies.first.target_id
        #session[:last_folio_id] = register.ordered_folio_proxies.last.target_id
    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Set the folio and image session variables when the user selects an option from the drop-down list
  def set_folio_and_image_drop_down

    begin

      folio_id = params[:folio_id].strip

      session[:folio_id] = folio_id
      session[:alt_image] = []

      if folio_id == ''
        session[:folio_image] = ''
      else
        q = SolrQuery.new
        response = q.solr_query('hasTarget_ssim:"' + session[:folio_id] + '"', fl='file_path_tesim', 2, 'preflabel_si asc')['response']

        if response['numFound'] > 1
          count = 0
          response['docs'].map do |result|
            if count == 0
              session[:folio_image] = result['file_path_tesim'][0]
            else
              session[:alt_image] << result['file_path_tesim'][0]
            end
            count += 1
          end
        else
          q.solr_query('hasTarget_ssim:"' + session[:folio_id] + '"', fl='file_path_tesim', 2, 'preflabel_si asc')['response']['docs'].map do |result|
            session[:folio_image] = result['file_path_tesim'][0]
          end
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Set the folio and image session variables, e.g. when the '>' or '<' buttons are clicked
  # action = 'prev_tesim' or 'next_tesim'
  def set_folio_and_image(action, id)

    begin

      next_id = ''
      next_image = ''

      if action != nil #&& id != nil
        # convert the list of folios in order into a hash so we can access the position of our id
        set_order
        hash = Hash[@order.map.with_index.to_a]
        if action == 'next_tesim'
          next_id = @order[hash[id].to_i + 1]
        elsif action == 'prev_tesim'
          next_id = @order[hash[id].to_i - 1]
        end
      end

      # Set the folio image session variable
      SolrQuery.new.solr_query('hasTarget_ssim:"' + next_id + '"', 'file_path_tesim', 1, sort='preflabel_si asc')['response']['docs'].map do |result|
        next_image = result['file_path_tesim'][0]
      end

      session[:alt_image] = []

      q = SolrQuery.new
      response = q.solr_query('hasTarget_ssim:"' + next_id + '"', fl='file_path_tesim', 2, 'preflabel_si asc')['response']

      if response['numFound'] > 1
        count = 0
        response['docs'].map do |result|
          if count == 0
            next_image = result['file_path_tesim'][0]
          else
            session[:alt_image] << result['file_path_tesim'][0]
          end
          count += 1
        end
      else
        q.solr_query('hasTarget_ssim:"' + next_id + '"', fl='file_path_tesim', 2, 'preflabel_si asc')['response']['docs'].map do |result|
          next_image = result['file_path_tesim'][0]
        end
      end

      session[:folio_id] = next_id
      session[:folio_image] = next_image

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Set the next (or previous) folio and image session variables (when the '>' or '<' buttons are clicked)
  # action = 'prev_tesim' or 'next_tesim'
  def set_folio_and_image_browse(action, id)

    begin

      next_id = ''
      next_image = ''

      if action != nil and id != nil
        # convert the list of folios in order into a hash so we can access the position of our id
        set_order
        hash = Hash[@order.map.with_index.to_a]
        if action == 'next_tesim'
          next_id = @order[hash[id].to_i + 1]
        elsif action == 'prev_tesim'
          next_id = @order[hash[id].to_i - 1]
        end
      end

      # Set the browse image
      SolrQuery.new.solr_query('hasTarget_ssim:"' + next_id + '"', 'file_path_tesim', 1)['response']['docs'].map do |result|
        next_image = result['file_path_tesim'][0]
      end

      session[:browse_id] = next_id
      session[:browse_image] = next_image

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Set @folio_list - this is used to display the folio drop-down list
  def set_folio_list

    begin

      @folio_list = []
      folio_hash = {}
      q = SolrQuery.new
      set_order
      # Get the list of folios in order
      @order.each do |o|
        q.solr_query('id:"' + o + '"', 'id,preflabel_tesim', rows=1)['response']['docs'].map.each do |res|
          folio_hash[res['id']] = res['preflabel_tesim'].join()
          @folio_list += [[res['id'], folio_hash[res['id']]]]
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Determines which message is displayed when the user clicks the 'Continue' button
  def is_entry_on_next_folio

    begin

      next_folio_id = ''

      # First get the next_folio_id...
      # convert the list of folios in order into a hash so we can access the position of our id
      set_order
      hash = Hash[@order.map.with_index.to_a]
      next_folio_id = @order[hash[session[:folio_id]].to_i + 1]


      @is_entry_on_next_folio = false

      # Then determine if an entry exists
      if next_folio_id != nil
        SolrQuery.new.solr_query('folio_ssim:"' + next_folio_id + '"', 'id', 1)['response']['docs'].map do |result|
          @is_entry_on_next_folio = true
        end
      end

      # Return value
      @is_entry_on_next_folio

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Determines if the 'Continues on next folio' row and 'Continues' button are to be displayed
  def is_last_entry(entry)

    begin

      @is_last_entry = false
      if entry != nil
        max_entry_no = get_max_entry_no_for_folio
        if entry.entry_no.to_i >= max_entry_no.to_i
          @is_last_entry = true
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Determines if this is the last entry on a folio which is continued from the previous folio
  # i.e. the previous folio 'continues_on' field is populated
  def is_last_entry_for_continues_on(entry)

    begin

      @is_last_entry_for_continues_on = false

      if entry != nil
        SolrQuery.new.solr_query('continues_on_tesim:' + session[:folio_id], 'id', 1, 'entry_no_si asc')['response']['docs'].map do |result|
          entry_count = SolrQuery.new.solr_query('folio_ssim:' + session[:folio_id], 'id', 100, 'id asc')['response']['docs'].map.size
          if entry_count <= 1
            @is_last_entry_for_continues_on = true
          end
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Determines if the 'New Entry' Tab and '(continues)' text are to be displayed
  def set_folio_continues_id

    begin

      @folio_continues_id = ''

      q = SolrQuery.new

      q.solr_query('folio_ssim:"' + session[:folio_id] + '"', 'id', 100)['response']['docs'].each do |result|
        entry_id = result['id']
        q.solr_query('id:"' + entry_id + '"', 'continues_on_tesim,entry_no_tesim', 1)['response']['docs'].each do |result|
          if result['continues_on_tesim'] != nil
            @folio_continues_id = result['entry_no_tesim'].join()
          end
        end
      end

      return @folio_continues_id

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # If the entry is continued onto the next folio, creates the entry and
  # sets the new session variables
  # Also sets the entry 'continues_on' attribute
  def create_next_entry(create_entry_status)

    begin

      next_folio_id = ''

      # Convert the list of folios in order into a hash so we can access the position of our id
      set_order
      hash = Hash[@order.map.with_index.to_a]
      next_folio_id = @order[hash[session[:folio_id]].to_i + 1]

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

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Get the max entry no for the folio
  # i.e used to automate the entry no when adding a new entry
  def get_max_entry_no_for_folio

    begin

      max_entry_no = 0

      SolrQuery.new.solr_query('folio_ssim:"' + session[:folio_id] + '"', 'entry_no_tesim', 100)['response']['docs'].each do |result|

        entry_no = result['entry_no_tesim'].join('').to_i

        if entry_no > max_entry_no
          max_entry_no = entry_no
        end
      end

      # Return max_entry_no
      max_entry_no

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Return list of registers (fedora id, register id and title), in order
  # Don't use @order here as this is registers NOT folios
  def get_registers_in_order

    begin

      # Get the collections so that we can get a list of registers in order
      registers = Hash.new
      q = SolrQuery.new
      # Get the ordered list of registers

      q.solr_query('has_model_ssim:OrderedCollection', 'id')['response']['docs'].map.each do |result|
        collection = result['id']

        q.solr_query('id:"' + collection + '/list_source"', 'ordered_targets_ssim')['response']['docs'].map.each do |res|
          order = res['ordered_targets_ssim']
          order.each do |o|
            q.solr_query('id:"' + o + '"', 'id,preflabel_tesim,reg_id_tesim')['response']['docs'].map.each do |r|
              registers[r['id']] = [r['reg_id_tesim'][0], r['preflabel_tesim'][0]]
            end
          end
        end
      end

      registers

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Check if webapp has timed out
  # Note that the session timeout value is set in config/initializers/session_store.rb
  def session_timed_out

    begin
      if session[:login] == '' || session[:login] == nil
        render 'timed_out/timed_out', :layout => 'timed_out'
      end
    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # This displays the timed out message for the browse folios, subject popup, person popup and place popup pages
  def session_timed_out_small

    begin
      if session[:login] == '' || session[:login] == nil
        render 'timed_out/timed_out_small', :layout => 'timed_out_small'
      end
    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Used in person / place popups to check that variable begings with 'http://' or 'https://'
  # and that url size is less than 200 characters
  def check_url(var_array, error, title)

    begin
      if var_array != nil
        max_length = 200
        var_array.each do |var|
          if var !~ /^https:\/\// && var !~ /^http:\/\//
            if error != '' then
              error = error + '<br/>'
            end
            error = error + "Please enter a valid URL for '" + title + "' (must start with http:// or https://)"
          elsif var.length > max_length
            if error != '' then
              error = error + '<br/>'
            end
            error = error + "Please enter a string less than #{max_length.to_s} characters"
          end
        end
      end

      return error
    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Set the entry tab list (i.e. at the top of the form)
  def set_entry_list

    begin

      # This is an array of arrays ('id' and 'entry_no')
      @entry_list = []

      SolrQuery.new.solr_query(q='has_model_ssim:Entry AND folio_ssim:' + session[:folio_id], fl='id,entry_no_tesim', rows=1000, sort='entry_no_si asc')['response']['docs'].map.each do |result|
        id = result['id']
        entry_no = result['entry_no_tesim'].join
        temp = []
        temp[0] = id
        temp[1] = entry_no
        @entry_list << temp
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Update rdf types
  def update_rdf_types(entry_params)

    begin

      unless entry_params["related_agents_attributes"].nil?
        entry_params["related_agents_attributes"].each do |key, value|
          if entry_params["related_agents_attributes"][key]['person_group'] == 'person'
            entry_params["related_agents_attributes"][key]["rdftype"] = ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedAgent', 'http://xmlns.com/foaf/0.1/Person', 'http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
          else
            entry_params["related_agents_attributes"][key]["rdftype"] = ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedAgent', 'http://xmlns.com/foaf/0.1/Group', 'http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
          end
        end
      end

      unless entry_params["related_places_attributes"].nil?
        entry_params["related_places_attributes"].each do |key, value|
          entry_params["related_places_attributes"][key]["rdftype"] = ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedPlace', 'http://schema.org/Place', 'http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
        end
      end

      unless entry_params["entry_dates_attributes"].nil?
        entry_params["entry_dates_attributes"].each do |key, value|
          entry_params["entry_dates_attributes"][key]["rdftype"] = ['http://dlib.york.ac.uk/ontologies/borthwick-registers#EntryDate', 'http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
          value.each do |k, v|
            if k == 'single_dates_attributes'
              unless v.class == String
                v.each do |ke, va|
                  entry_params["entry_dates_attributes"][key][k][ke]["rdftype"] = ['http://dlib.york.ac.uk/ontologies/borthwick-registers#SingleDate', 'http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
                end
              end
            end
          end
        end
      end

      entry_params

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # This method adds adds Related Agent ids to the relatedPlaceFor field in Related Place
  def update_related_places

    begin
      # Get each Related Place for the Entry...
      q = SolrQuery.new
      query = 'relatedPlaceFor_ssim:"' + @entry.id + '"'
      q.solr_query(query, 'id,place_as_written_tesim', 50)['response']['docs'].each do |result|
        unless result['place_as_written_tesim'].nil?
          name = result['place_as_written_tesim'][0]
          # Get each person_related_place string (i.e. as chosen from the drop-down list) for each Related Agent in the Entry
          query = 'relatedAgentFor_ssim:"' + @entry.id + '" AND person_related_place_tesim:"' + name + '"'
          q.solr_query(query, 'id,person_related_place_tesim', 50)['response']['docs'].each do |result2|
            # Add the Related Person id to the related_place_for field in the Related Place
            place = RelatedPlace.find(result['id'])
            places = place.related_agent
            places += [RelatedAgent.find(result2['id'])]
            place.related_agent = places
            place.save
          end
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # This method adds adds Related Agent ids to the relatedPersonFor field in Related Place
  def update_related_people

    begin

      # Get each Related Person for the Entry...
      q = SolrQuery.new
      query = 'relatedAgentFor_ssim:"' + @entry.id + '"'
      q.solr_query(query, 'id,person_as_written_tesim', 50)['response']['docs'].each do |result|
        unless result['person_as_written_tesim'].nil?
          name = result['person_as_written_tesim'][0]
          # Get each person_related_place string (i.e. as chosen from the drop-down list) for each Related Agent in the Entry
          query = 'relatedAgentFor_ssim:' + @entry.id + ' AND person_related_person_tesim:"' + name + '"'
          q.solr_query(query, 'id,person_related_person_tesim', 50)['response']['docs'].each do |result2|
            # Add the Related Person id to the related_agent_for field in the Related Person
            person = RelatedAgent.find(result['id'])
            people = person.related_agent
            people += [RelatedAgent.find(result2['id'])]
            person.related_agent = people
            person.save
          end
        end
      end

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Return array of folio / entry numbers which contain the specified concept / subject
  def get_existing_location_list(type, element_id)

    begin

      existing_location_list = []

      q = SolrQuery.new

      # One solr search required for these types - this is because they exist in the Entry object
      if type == 'entry_type' or type == 'language' or type == 'section_type' or type == 'subject'

        search_term2 = type + '_tesim:' + element_id
        q.solr_query(search_term2, fl='id, folio_ssim, entry_no_tesim', rows=100000, sort='id ASC')['response']['docs'].map do |result|
          element = []
          id = result['id']
          folio_id = result['folio_ssim'].join
          entry_no = result['entry_no_tesim'].join
          folio = q.solr_query('id:' + folio_id, fl='preflabel_tesim', rows=100000, sort='id ASC')['response']['docs'].map.first['preflabel_tesim'].join
          element[0] = id
          element[1] = folio_id
          element[2] = folio + ' (Entry No = ' + entry_no + ')'
          existing_location_list << element
        end

        # Two solr searches required for these types - this is because they exist in sub-objects of the ENtry object
        # i.e. Date, Related Place and Related Agent
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

        # First find the Date, Related Place or Related Agent objects which contain the element
        q.solr_query(search_term1 + ':' + element_id, fl=fl_term, rows=100000, sort='id ASC')['response']['docs'].map do |result|
          search_term2 = 'id:' + result[fl_term].join
          # Then find out which entries contain them
          q.solr_query(search_term2, fl='id, folio_ssim, entry_no_tesim', rows=100000, sort='id ASC')['response']['docs'].map do |result|
            element = []
            id = result['id']
            folio_id = result['folio_ssim'].join
            entry_no = result['entry_no_tesim'].join
            folio = q.solr_query('id:' + folio_id, fl='preflabel_tesim', rows=100000, sort='id ASC')['response']['docs'].map.first['preflabel_tesim'].join
            element[0] = id
            element[1] = folio_id
            element[2] = folio + ' (Entry No = ' + entry_no + ')'
            existing_location_list << element
          end
        end
      end

      return existing_location_list

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Returns concept_scheme id for the particular concept
  def get_concept_scheme_id(list_type)

    begin

      # this won't work for local lists

      concept_list_type = "#{list_type.downcase}s"
      concept_list_type = concept_list_type.sub ' ', '_'
      response = SolrQuery.new.solr_query(q='has_model_ssim:ConceptScheme AND preflabel_tesim:' + concept_list_type, fl='id', rows=1)
      concept_scheme_id = response['response']['docs'][0]['id']
      return concept_scheme_id

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end
  end

  # Return hash of parent /child ids and labels
  def get_parent_child_list

    begin

      parent_child_list = {}
      parent_child_list[@concept.id] = @concept.preflabel
      q = SolrQuery.new

      q.solr_query('broader_tesim:' + @concept.id, fl='id, preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
        id = result['id']
        preflabel = result['preflabel_tesim'].join
        parent_child_list[id] = preflabel
        q.solr_query('broader_tesim:' + id, fl='id, preflabel_tesim', rows=1000, sort='id ASC')['response']['docs'].map do |result|
          id2 = result['id']
          preflabel2 = result['preflabel_tesim'].join
          parent_child_list[id2] = preflabel2
        end
      end

      return parent_child_list

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Writes error message to the log
  def log_error(method, file, error)
    time = Time.now.strftime('[%d/%m/%Y %H:%M:%S]').to_s
    logger.error "#{time} EXCEPTION IN #{file}, method='#{method}' [#{error}]"
  end

end
