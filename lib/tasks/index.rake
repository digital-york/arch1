require 'dotenv/tasks'

namespace :index do

    # bundle exec rake index:all_entries
    desc "index all entries to Solr"
    task all_entries: :environment do
        # Start timer
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        # Find all entries
        solr = SolrQuery.new
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
            rescue => e
                print "Error #{e} while indexing #{entry_id}"
            end
        end
       # Stop timer
       ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
       seconds = ending - starting
       hours = seconds/3600
       print "Total running time: #{hours}h \n"
    end

    # bundle exec rake index:all_places
    desc "index all places to Solr"
    task all_places: :environment do
        # Start timer
        starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        # Find all places
        solr = SolrQuery.new
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
            rescue => e
                print "Error #{e} while indexing #{place_id}"
            end
        end
       # Stop timer
       ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
       seconds = ending - starting
       hours = seconds/3600
       print "Total running time: #{hours}h \n"
    end

   # bundle exec rake index:all_single_dates
   desc "re-index all single dates to Solr"
   task all_single_dates: :environment do
       # Start timer
       starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
       # Find all dates
       solr = SolrQuery.new
       query = 'has_model_ssim:SingleDate'
       dates_response = solr.solr_query(query, 'id,date_tesim', rows=2147483647)

       total = dates_response['response']['numFound'].to_i
       index = 1
       dates_response['response']['docs'].map do |date|
           begin
               date_id = date['id']
               date_label = date['date_tesim'][0] unless date['date_tesim'].blank?
               print "indexing #{index} / #{total}: #{date_id} #{date_label} \n"
               index += 1
               ActiveFedora::Base.find(date_id).update_index
           rescue => e
               print "Error #{e} while indexing #{date_id} \n"
           end
       end
       # Stop timer
       ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
       seconds = ending - starting
       hours = seconds/3600
       print "Total running time: #{hours}h \n"
   end
end
