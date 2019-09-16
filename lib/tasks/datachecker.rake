require 'dotenv/tasks'

namespace :datachecker do

    # bundle exec rake datachecker:compare_solr[SOLR_URL1,SOLR_URL_2,OUTPUT_FILE_NAME]
    desc "Compare data between 2 Solr instances"
    task :compare_solr, [:solr1,:solr2,:output_file] => [:environment] do |t, args|
        solr1  = args[:solr1]
        solr2  = args[:solr2]
        o_file = args[:output_file]

        puts "Loading data from: #{solr1} ..."
        id1 = get_ids(solr1)

        puts "Loading data from: #{solr2} ..."
        id2 = get_ids(solr2)

        puts "Comparing..."
        solr1_only = id1-id2
        solr2_only = id2-id1

        puts "Generating reports..."
        output_string1  = "Objects only in #{solr1}\n"
        output_string1 += "------------#{solr1_only.size}------------\n"
        unique_models1 = []
        solr1_only.each do |s|
            output_string1 += s.to_s + "\n"
            unique_models1 << s.split(":")[0] unless (s.split(":").nil? or unique_models1.include? s.split(":")[0])
        end
        output_string1 += "------------#{solr1_only.size}------------\n"
        file1 = File.open(o_file + "_1", "w")
        file1.puts output_string1
        file1.puts unique_models1.to_s
        file1.close

        output_string2  = "Objects only in #{solr2}\n"
        output_string2 += "------------#{solr2_only.size}------------\n"
        unique_models2 = []
        solr2_only.each do |s|
            output_string2 += s.to_s + "\n"
            unique_models2 << s.split(":")[0] unless (s.split(":").nil? or unique_models2.include? s.split(":")[0])
        end
        output_string2 += "------------#{solr2_only.size}------------\n"
        file2 = File.open(o_file + "_2", "w")
        file2.puts output_string2
        file2.puts unique_models2.to_s
        file2.close
    end

    private
      def get_ids(solr_url)
          ids = []
          solr_query = '*:*'
          solr = RSolr.connect :url => solr_url
          response = solr.get 'select', :params => {
              :q=>"#{solr_query}",
              :start=>0,
              :rows=>1000000
          }
          number_of_objects = response['response']['numFound']
          if number_of_objects > 0
              puts "Total: #{number_of_objects}"
              puts '------------------------------'

              response['response']['docs'].each do |doc|
                  #ids << doc['id']
                  if doc['has_model_ssim'].nil?
                      ids << doc['id']
                  else
                      ids << doc['has_model_ssim'][0]+':'+doc['id']
                  end
              end
          end
          ids
      end

end
