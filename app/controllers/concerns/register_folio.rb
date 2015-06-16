module RegisterFolio

  # Get the first and last folio in the folio list and store as session variables so that the image
  # '<' or '>' button is greyed out if folio is equal to the first or last one
  def get_first_and_last_folio

    #TODO get this dynamically
    @register = Register.all.first.id

    SolrQuery.new.solr_query('id:"' + @register + '"', 'fst_tesim', 1)['response']['docs'].map do |result|
      session[:first_folio] = result['fst_tesim'][0]
    end

    SolrQuery.new.solr_query('id:"' + @register + '"', 'lst_tesim', 1)['response']['docs'].map do |result|
      session[:last_folio] = result['lst_tesim'][0]
    end

  end

  # Set the register, folio and folio name session variables (i.e. those chosen from the drop-down lists) for the current folio
  def get_current_folio

    #TODO SET THE FOLIO NAME VARIABLE

    session[:register_choice] = params[:register_choice].strip
    session[:folio_choice] = params[:folio_choice].strip

    SolrQuery.new.solr_query('hasTarget_ssim:"' + session[:folio_choice] + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      session[:image] = result['file_tesim'][0]
    end

  end

  # Get the next image and set the session variables when the '> or '<' buttons are clicked'
  def get_next_image(button_action)

    if button_action == 'forward'
      dir = 'next_tesim'
    else

      dir = 'prev_tesim'
    end

    next_folio = ''
    SolrQuery.new.solr_query('proxyFor_ssim:"' + session[:folio_choice] + '"', dir, 1)['response']['docs'].map do |result|
      next_folio = result[dir][0]
    end

    SolrQuery.new.solr_query('hasTarget_ssim:"' + next_folio + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      session[:image] = result['file_tesim'][0]
    end

    session[:folio_choice] = next_folio

  end

  # Used in methods above and to display the folio drop-down list on the view pages
  def get_folios
    puts
    puts "GET_FOLIOS"
    start_time = Time.now
    #TODO get this dynamically
    @register = Register.first.id # Takes about 3 seconds
    #puts "Elapsed Time 1 = #{Time.now - start_time}"
    @folios = []
    foltype = FolioTerms.new('subauthority')
    face = FolioFaceTerms.new('subauthority')
    #puts "Elapsed Time 2 = #{Time.now - start_time}"
    # Added 'sort ASC' so that drop-down list is sorted (py)
    q = SolrQuery.new.solr_query('has_model_ssim:"Folio" AND isPartOf_ssim:"' + @register + '"', 'id, folio_type_tesim, folio_no_tesim, folio_face_tesim', 1000, 'id ASC')
    #puts "Elapsed Time 3 = #{Time.now - start_time}"
    # Takes about 2.5 seconds
    q['response']['docs'].map do |result|
      ftype = foltype.find_value_string(result['folio_type_tesim'][0])[0]
      fface = face.find_value_string(result['folio_face_tesim'][0])[0]
      if fface != 'undefined'
        fface = ' ' + fface
      else
        fface = ''
      end
      @folios += [[result['id'], ftype + ' ' + result['folio_no_tesim'][0] + fface ]]
    end
    #@register = 'Abp Reg 12'
    #@folios = []
    #f = File.open(Rails.root + 'app/assets/files/folio_temp_list.txt', "r")
    #f.each_line do |ln|
    #  arr = ln.split(/-/)
    #  x = [[arr[0].strip, arr[1].strip]]
    #  @folios += x
    #end
    puts "Elapsed Time 1 = #{Time.now - start_time}"
  end

  def get_registers
    @registers = []
    SolrQuery.new.solr_query('has_model_ssim:"Register"', 'id, reg_id_tesim', 100)['response']['docs'].map do |result|
      @registers += [[result['id'],result['reg_id_tesim'][0]]]
    end
    @registers
  end

end