class PersonTerms

  include Qa::Authorities::WebServiceBase

  attr_reader :subauthority

  def initialize(subauthority)
    @subauthority = subauthority
  end

  # Gets the ConceptScheme, etc
  def terms_id
    parse_terms_id_response(SolrQuery.new.solr_query(q='rdftype_tesim:"http://www.w3.org/2004/02/skos/core#ConceptScheme" AND preflabel_tesim:"people"'))
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

  private

  # Reformats the data received from the service
  def parse_authority_response(response)
    response['response']['docs'].map do |result|

      { 'id' => result['id'],
        'label' => result['preflabel_tesim'].join,
        'family' => if result['family_tesim'] then result['family_tesim'].join end,
        'pre_title' => if result['pre_title'] then result['pre_title'].join end,
        'given' => if result['given_tesim'] then result['given_tesim'].join end,
        'dates' => if result['dates_tesim'] then result['dates_tesim'].join end,
        'epithet' => if result['epithet_tesim'] then result['epithet_tesim'].join end,
        'post_title' => if result['post_preflabel_tesim'] then result['post_preflabel_tesim'].join end
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

end
