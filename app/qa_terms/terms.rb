class Terms

  attr_reader :subauthority

  def initialize(subauthority)
    @subauthority = subauthority
  end

  def terms_id
    parse_terms_id_response(SolrQuery.new.solr_query(q='rdftype_tesim:http://www.w3.org/2004/02/skos/core#ConceptScheme AND title_tesim:"' + terms_list + '"'))
  end

  def all
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '"',fl='id,preflabel_tesim',rows=1000,sort='preflabel_si asc'))
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