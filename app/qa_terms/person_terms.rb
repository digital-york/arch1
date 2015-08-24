class PersonTerms

  include Qa::Authorities::WebServiceBase

  attr_reader :subauthority

  def initialize(subauthority)
    @subauthority = subauthority
  end

  # Gets the ConceptScheme, etc
  def terms_id
    parse_terms_id_response(SolrQuery.new.solr_query(q='rdftype_tesim:"http://www.w3.org/2004/02/skos/core#ConceptScheme" AND title_tesim:"persons"'))
  end

  def all
    sort_order = 'preflabel_si asc'
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '"',fl='',rows=1000,sort=sort_order))
  end

  def find id
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND id:"' + id + '"'))
  end

  def find_id val
    parse_terms_id_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND preflabel_tesim:"' + val + '"', fl='id'))
  end

  def search q
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND preflabel_tesim:"' + q + '"', fl=''))
  end

  # Dereference ids into strings in order to display them, e.g. on the form and the folio drop-down list (py)
  def get_str_from_id(id, type)
    parse_terms_response(SolrQuery.new.solr_query(q='id:' + id, fl=type, rows='1'), type);
  end

  private

  # Reformats the data received from the service
  def parse_authority_response(response)
    response['response']['docs'].map do |result|

      { 'id' => result['id'],
        'label' => result['preflabel_tesim'],
        'family' => result['family_tesim'],
        'pre_title' => result['pre_title'],
        'given' => result['given_tesim'],
        'dates' => result['dates_tesim'],
        'epithet' => result['epithet_tesim'],
        'post_title' => result['post_title_tesim']
      }
    end
  end

  def parse_terms_id_response(response)
    i = ''
    response['response']['docs'].map do |result|
      i = result['id']
    end
    i
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
