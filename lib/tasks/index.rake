require 'dotenv/tasks'

namespace :index do

    # bundle exec rake index:all_entries
    desc "index all entries to Solr"
    task all_entries: :environment do
        solr = SolrQuery.new
        # Find all entries
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

    # bundle exec rake index:all_places
    desc "index all places to Solr"
    task all_places: :environment do
        solr = SolrQuery.new
        # Find all places
        query = 'has_model_ssim:Place'
        place_response = solr.solr_query(query, 'id,preflabel_tesim', rows=2147483647)

        total = place_response['response']['numFound'].to_i
        index = 1
        place_response['response']['docs'].map do |place|
            begin
                place_id = place['id']
                place_label = place['preflabel_tesim'][0]
                puts "indexing #{index} / #{total}: #{place_id} #{place_label}"
                index += 1
                ActiveFedora::Base.find(place_id).update_index
            rescue
                print "Error while indexing #{place_id}"
            end
        end
    end
end
