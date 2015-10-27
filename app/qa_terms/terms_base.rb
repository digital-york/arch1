class TermsBase

  attr_reader :subauthority

  def initialize(subauthority)
    @subauthority = subauthority
  end

  # Gets the ConceptScheme, etc
  def terms_id
    parse_terms_id_response(SolrQuery.new.solr_query(q='rdftype_tesim:"http://www.w3.org/2004/02/skos/core#ConceptScheme" AND preflabel_tesim:"' + terms_list + '"'))
  end

  def all
    # 'Languages' are sorted by id so that 'Latin' is first
    sort_order = 'preflabel_si asc'
    if terms_list == 'languages'
      sort_order = 'id asc'
    end
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '"',fl='id,preflabel_tesim',rows=1000,sort=sort_order))
  end

  def find id
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND id:"' + id + '"',fl='id,preflabel_tesim'))
  end

  def find_id val
    parse_terms_id_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND preflabel_tesim:"' + val + '"', fl='id'))
  end

  def find_value_string id
    parse_string(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND id:"' + id + '"', fl='preflabel_tesim'))
  end

  def search q
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND preflabel_tesim:"' + q + '"',fl='id,preflabel_tesim'))
  end

  # Dereference id into a string for display purposes - e.g. test:101 -> 'abbey'
  def get_str_from_id(id, type)
    response = SolrQuery.new.solr_query(q='id:"' + id + '"', fl=type, rows='1')
    parse_terms_response(response, type);
  end

  # Construct place same_as string for the view / edit pages
  def get_place_same_as(same_as)

    response = SolrQuery.new.solr_query(q='id:' + same_as, fl='place_name_tesim, parent_ADM4_tesim, parent_ADM3_tesim, parent_ADM2_tesim, parent_ADM1_tesim', rows='1')

    place_same_as = ''

    response['response']['docs'].map do |result|

      place_name = result['place_name_tesim']
      parent_ADM4 = result['parent_ADM4_tesim']
      parent_ADM3 = result['parent_ADM3_tesim']
      parent_ADM2 = result['parent_ADM2_tesim']
      parent_ADM1 = result['parent_ADM1_tesim']

      if (place_name != nil && place_name != '')
        place_same_as = place_name.join()
        if parent_ADM4 != nil then
          place_same_as = "#{place_same_as}, #{parent_ADM4.join()}"
        end
        if parent_ADM3 != nil then
          place_same_as = "#{place_same_as}, #{parent_ADM3.join()}"
        end
        if parent_ADM2 != nil then
          place_same_as = "#{place_same_as}, #{parent_ADM2.join()}"
        end
        if parent_ADM1 != nil then
          place_same_as = "#{place_same_as}, #{parent_ADM1.join()}"
        end
      else
        place_same_as = "ERROR"
      end
    end

    return place_same_as
  end

  # Construct person same_as string for the view / edit pages
  def get_person_same_as(same_as)

    response = SolrQuery.new.solr_query(q='id:' + same_as, fl='family_tesim, pre_title_tesim, given_name_tesim, dates_tesim, post_title_tesim, epithet_tesim', rows='1')

    person_same_as = ''

    response['response']['docs'].map do |result|

      family = result['family_tesim']
      pre_title = result['pre_title_tesim']
      given_name = result['given_name_tesim']
      dates = result['dates_tesim']
      post_title = result['post_title_tesim']
      epithet = result['epithet_tesim']

      if family != nil && family != ''
        person_same_as = family.join()
        if pre_title != nil then
          person_same_as = "#{person_same_as}, #{pre_title.join()}"
        end
        if given_name != nil then
          person_same_as = "#{person_same_as}, #{given_name.join()}"
        end
        if dates != nil then
          person_same_as = "#{person_same_as}, #{dates.join()}"
        end
        if post_title != nil then
          person_same_as = "#{person_same_as}, #{post_title.join()}"
        end
        if epithet != nil then
          person_same_as = "#{person_same_as}, #{epithet.join()}"
        end
      else
        person_same_as = "ERROR"
      end

    end

    return person_same_as
  end

  # Returns an array of hashes (top-level terms) which contain an array of hashes (middle-level terms), etc
  # These are dereferenced in the subjects pop-up to dispay the subject list
  def all_top_level_subject_terms

    # all_terms_list = []
    # middle_level_list = []
    # bottom_level_list = []

    top_level_list = parse_authority_response(SolrQuery.new.solr_query(q='istopconcept_tesim:true',fl='id,preflabel_tesim',rows=1000,sort='preflabel_si asc'))

    top_level_list.each_with_index do |t1, index|

      id = t1['id']

      middle_level_list = parse_authority_response(SolrQuery.new.solr_query(q='broader_tesim:' + id,fl='id,preflabel_tesim',rows=1000, sort='preflabel_si asc'))

      t1[:elements] = middle_level_list

      middle_level_list.each_with_index do |t2, index|

        id2 = t2['id']

        bottom_level_list = parse_authority_response(SolrQuery.new.solr_query(q='broader_tesim:' + id2,fl='id,preflabel_tesim',rows=1000, sort='preflabel_si asc'))

        t2[:elements] = bottom_level_list

      end

    end

    return top_level_list

  end

  # Returns an array of hashes (top-level terms) which contain an array of hashes (middle-level terms), etc
  # These are dereferenced in the subjects pop-up to dispay the subject list
  def get_subject_list_top_level

    top_level_list = parse_authority_response(SolrQuery.new.solr_query(q='istopconcept_tesim:true',fl='id,preflabel_tesim',rows=1000,sort='preflabel_si asc'))

    top_level_list.each_with_index do |t1, index|

      id = t1['id']

      second_level_list = parse_authority_response(SolrQuery.new.solr_query(q='broader_tesim:' + id,fl='id,preflabel_tesim',rows=1000, sort='preflabel_si asc'))

      t1[:elements] = second_level_list

      second_level_list.each_with_index do |t2, index|

        id2 = t2['id']

        third_level_list = parse_authority_response(SolrQuery.new.solr_query(q='broader_tesim:' + id2,fl='id,preflabel_tesim',rows=1000, sort='preflabel_si asc'))

        t2[:elements] = third_level_list
      end
    end

    return top_level_list
  end

  def get_subject_list_second_level(id)

    top_level_list = parse_authority_response(SolrQuery.new.solr_query(q='istopconcept_tesim:true AND id:' + id,fl='id,preflabel_tesim',rows=1000,sort='preflabel_si asc'))

    top_level_list.each do |t1|

      #id = t1['id']

      second_level_list = parse_authority_response(SolrQuery.new.solr_query(q='broader_tesim:' + id,fl='id,preflabel_tesim',rows=1000, sort='preflabel_si asc'))

      t1[:elements] = second_level_list

      second_level_list.each do |t2|

        id2 = t2['id']

        third_level_list = parse_authority_response(SolrQuery.new.solr_query(q='broader_tesim:' + id2,fl='id,preflabel_tesim',rows=1000, sort='preflabel_si asc'))

        t2[:elements] = third_level_list
      end
    end

    return top_level_list
  end


  private

  # Reformats the data received from the service
  def parse_authority_response(response)
    response['response']['docs'].map do |result|
      {'id' => result['id'], 'label' => result['preflabel_tesim']}
    end
  end

  def parse_terms_id_response(response)
    id = ''
    response['response']['docs'].map do |result|
      id = result['id']
    end
    id
  end

  def parse_string(response)
    str = ''
    response['response']['docs'].map do |result|
      str = result['preflabel_tesim']
    end
    str
  end

  # General method to parse ids into strings (py)
  def parse_terms_response(response, type)

    str = ''

    response['response']['docs'].map do |result|
      if result['numFound'] != '0'
        str = result[type]
        if str.class == Array
          str = str.join() # 'join' is used to convert an array into a string because otherwise an error occurs
        end
      end
    end

    return str
  end

end
