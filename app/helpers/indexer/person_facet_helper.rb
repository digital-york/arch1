module Indexer
    module PersonFacetHelper
        @@solr = SolrQuery.new

        # search person_same_as_facet_ssim facet field values from entry
        # e.g.
        # pry(main)> Indexer::PersonFacetHelper.s_get_person_facets_from_entry('5138jf534')
        def self.s_get_person_facets_from_entry(entry_id)
            person_facets = []

            # Find linked RelatedAgent
            query = 'has_model_ssim:RelatedAgent AND relatedAgentFor_ssim:' + entry_id
            related_agent_response = @@solr.solr_query(query, 'id,person_same_as_facet_ssim')

            related_agent_response['response']['docs'].map do |related_agent|
                if related_agent.include? 'person_same_as_facet_ssim'
                    related_agent['person_same_as_facet_ssim'].each do |person_same_as|
                        person_facets << person_same_as
                    end
                end
            end
            person_facets
        end

    end
end