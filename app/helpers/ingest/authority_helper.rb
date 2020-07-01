module Ingest
    module AuthorityHelper
        # search authority ids by the given label
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_authority_ids(authority_label)
            ids = nil
            SolrQuery.new.solr_query("preflabel_tesim:\"#{authority_label}\"")['response']['docs'].map do |r|
                ids = r['id']
            end
        end

        # find language object ids from Solr
        def self.s_get_language_object_id(languages)
            language_ids = []
            languages.each do |lang|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"languages"', 'id')
                # first, query ConceptSchema for languages
                response['response']['docs'].map do |l|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + l['id'] + '" AND preflabel_tesim:"' + lang.downcase + '"', 'id')
                    resp['response']['docs'].map do |la|
                        language_ids += [la['id']]
                    end
                end
            end
            language_ids
        end
    end
end