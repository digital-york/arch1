require 'dotenv/tasks'

namespace :index do

    # bundle exec rake index:all_entries
    desc "index all entries to Solr"
    task all_entries: :environment do
        solr = SolrQuery.new
        # Find linked EntryDates
        query = 'has_model_ssim:Entry'
        entry_response = solr.solr_query(query, 'id,entry_folio_facet_ssim', rows=2147483647)

        total = entry_response['response']['numFound'].to_i
        index = 1
        entry_response['response']['docs'].map do |entry|
            begin
                entry_id = entry['id']
                entry_label = entry['entry_folio_facet_ssim'][0]
                puts "indexing #{index} / #{total}: #{entry_id} #{entry_label}"
                index += 1
                ActiveFedora::Base.find(entry_id).update_index
            rescue
                print "Error while indexing #{entry_id}"
            end
        end
    end
end
