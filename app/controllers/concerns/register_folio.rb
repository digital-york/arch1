module RegisterFolio

  # Get the first and last folio in the folio list and store as session variables so that the image
  # buttons are greyed out if the folio is equal to the first or last image
  def get_first_and_last_folio

    SolrQuery.new.solr_query('id:"' + session[:register_choice] + '"', 'fst_tesim', 1)['response']['docs'].map do |result|
      session[:first_folio] = result['fst_tesim'][0]
    end

    SolrQuery.new.solr_query('id:"' + session[:register_choice] + '"', 'lst_tesim', 1)['response']['docs'].map do |result|
      session[:last_folio] = result['lst_tesim'][0]
    end

  end

  # Set the folio and image when the user selects an option from the drop-down list
  def set_folio

    session[:folio_choice] = params[:folio_choice].strip

    SolrQuery.new.solr_query('hasTarget_ssim:"' + session[:folio_choice] + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      session[:image] = result['file_tesim'][0]
    end

    # Not sure if we need folio_title anymore because it is not displayed in the small image title - instead there is the drop-down list
    #SolrQuery.new.solr_query('id:"' + session[:folio_choice] + '"' , 'title_tesim', 1)['response']['docs'].map do |result|
    #  session[:folio_title] = result['title_tesim'][0]
    #end

  end

  # Set the next (or previous) folio and the appropriate image when the '>' or '<' buttons are clicked
  def set_folio_next_previous(action)

    if action == 'next'
      type = 'next_tesim'
    else
      type = 'prev_tesim'
    end

    next_folio = ''

    # Determine the next or previous folio
    SolrQuery.new.solr_query('proxyFor_ssim:"' + session[:folio_choice] + '"', type, 1)['response']['docs'].map do |result|
      next_folio = result[type][0]
    end

    # Determine the next image
    SolrQuery.new.solr_query('hasTarget_ssim:"' + next_folio + '"', 'file_tesim', 1)['response']['docs'].map do |result|
      session[:image] = result['file_tesim'][0]
    end

    session[:folio_choice] = next_folio

  end

  # Used in methods above and to display the folio drop-down list on the view pages
  def get_folios

    #puts "GET_FOLIOS"

    #start_time = Time.now

    #TODO get this dynamically
    #@register = Register.first.id # Takes about 3 seconds

    @register = session[:register_choice]

    #puts @register

    #puts "Elapsed Time 1 = #{Time.now - start_time}"
    @folios = []

    folio_type_terms = FolioTerms.new('subauthority')
    folio_face_terms = FolioFaceTerms.new('subauthority')

    # Added 'sort ASC' so that drop-down list is sorted (py)
    q = SolrQuery.new.solr_query('has_model_ssim:"Folio" AND isPartOf_ssim:"' + @register + '"', 'id, folio_type_tesim, folio_no_tesim, folio_face_tesim', 1000, 'id ASC')

    q['response']['docs'].each_with_index do |result, index|

      #puts result

      begin

        begin
          folio_type = folio_type_terms.find_value_string(result['folio_type_tesim'][0])[0]
        rescue
          #puts "folio_type problem"
        end

        begin
          folio_face = folio_face_terms.find_value_string(result['folio_face_tesim'][0])[0]
        rescue
          #puts "folio_face problem"
        end

        if folio_face != 'undefined'
          folio_face = ' ' + folio_face
        else
          folio_face = ''
        end

        @folios += [[result['id'], folio_type + ' ' + result['folio_no_tesim'][0] + folio_face]]

      rescue
        #puts "There was a problem with the data! #{result}"
      end
    end
  end

  #def get_registers
  #  @registers = []
  #  SolrQuery.new.solr_query('has_model_ssim:"Register"', 'id, reg_id_tesim', 100)['response']['docs'].map do |result|
  #    @registers += [[result['id'],result['reg_id_tesim'][0]]]
  #  end
  #  @registers
  #end

end