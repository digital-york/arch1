module Indexer
    module DateFacetHelper
        @@solr = SolrQuery.new

        # get date_facets from solr document
        # Indexer::DateFacetHelper.s_get_date_facets_from_entry(solr_doc)
        def self.s_get_date_facets_from_solr_doc(solr_doc)
            if solr_doc['has_model_ssim'].include? 'Entry'
                return Indexer::DateFacetHelper.s_get_date_facets_from_entry(solr_doc['id'])
            end
        end

        # search facet field values from entry
        # The prefix 's_' is the convention here, means retrieving data from Solr
        # e.g.
        # pry(main)> Indexer::DateFacetHelper.s_get_date_facets_from_entry('7p88cm19w')
        # => [["1398", "1398"], ["1398/08/24", "1398/09/05"]] 
        def self.s_get_date_facets_from_entry(entry_id)
            date_facets = []
            date_full = []

            # Find linked EntryDates
            query = 'has_model_ssim:EntryDate AND entryDateFor_ssim:' + entry_id
            entry_date_response = @@solr.solr_query(query, 'id')

            entry_date_response['response']['docs'].map do |entry_date|
                entry_date_id = entry_date['id']
                # Find linked SingleDates:
                query2 = 'has_model_ssim:SingleDate AND dateFor_ssim:' + entry_date_id
                single_date_response = @@solr.solr_query(query2, 'id,date_tesim')
                single_date_response['response']['docs'].map do |single_date|
                    if single_date.include? 'date_tesim'
                        single_date['date_tesim'].each do |dt|
                            date_facets << dt.split('/')[0]
                            date_full << dt
                        end
                    end
                end
            end

            [date_facets, date_full]
        end

    end
end