class TermsBase

  attr_reader :subauthority

  def initialize(subauthority)
    @subauthority = subauthority
  end

  # Gets the ConceptScheme, etc
  def terms_id
    parse_terms_id_response(SolrQuery.new.solr_query(q='rdftype_tesim:"http://www.w3.org/2004/02/skos/core#ConceptScheme" AND title_tesim:"' + terms_list + '"'))
  end

  def all
    # 'Languages' are sorted by id so that 'Latin' is first
    sort_order = 'preflabel_si asc'
    if terms_list == 'languages'
      sort_order = 'id asc'
    end
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '"',fl='id,preflabel_tesim',rows=1000,sort=sort_order))
  end

  # Returns an array of hashes (top-level terms) which contain an array of hashes (middle-level terms), etc
  # These are dereferenced in the subjects pop-up to dispay the subject list
  def all_top_level_subject_terms

    all_terms_list = []
    middle_level_list = []
    bottom_level_list = []

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

  # Dereference ids into strings in order to display them, e.g. on the form and the folio drop-down list (py)
  def get_str_from_id(id, type)
    parse_terms_response(SolrQuery.new.solr_query(q='id:' + id, fl=type,rows='1'), type);
  end

  private

  # Reformats the data received from the service
  def parse_authority_response(response)
    response['response']['docs'].map do |result|
      {'id' => result['id'], 'label' => result['preflabel_tesim']}
    end
  end

  def parse_terms_id_response(response)
    i = ''
    response['response']['docs'].map do |result|
      i = result['id']
    end
    i
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
        str = result[type].join('') # 'join' is used to convert an array into a string because otherwise an error occurs
      end
    end
    str
  end

end
