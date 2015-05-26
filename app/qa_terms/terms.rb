class Terms

  attr_reader :subauthority
  def initialize(subauthority)
    @subauthority = subauthority
  end

  def terms_id
    parse_terms_id_response(SolrQuery.new.solr_query(q='rdftype_tesim:http://www.w3.org/2004/02/skos/core#ConceptScheme AND title_tesim:"' + terms_list + '"'))
  end

  def all
    puts 'inScheme_ssim:"' + terms_id + '"'
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '"',fl='id,preflabel_tesim',rows=1000,sort='preflabel_si asc'))
  end

  def find id
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND id:"' + id + '"',fl='id,preflabel_tesim'))
  end

  def search q
    parse_authority_response(SolrQuery.new.solr_query(q='inScheme_ssim:"' + terms_id + '" AND preflabel_tesim:"' + q + '"',fl='id,preflabel_tesim'))
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
end
