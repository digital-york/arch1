require 'dotenv/tasks'
require 'json'
require 'faraday'

namespace :datachecker do
    FIELDS_TO_CHECK = {
        "Register" => %w[
            thumbnail_url_tesim
            preflabel_tesim
            date_tesim
            isPartOf_ssim
            reg_id_tesim
            date_facet_ssim
        ],
        "Folio" => %w[
            preflabel_tesim
            isPartOf_ssim
        ],
        "Entry" => %w[
            folio_ssim
            entry_no_tesim
            entry_type_tesim
            section_type_tesim
            language_tesim
            subject_tesim
            entry_type_facet_ssim
            entry_type_new_tesim
            entry_type_search
            section_type_facet_ssim
            section_type_new_tesim
            section_type_search
            language_new_tesim
            language_facet_ssim
            language_search
            subject_facet_ssim
            subject_new_tesim
            subject_search
            entry_register_facet_ssim
            entry_folio_facet_ssim
            entry_place_same_as_facet_ssim
            entry_person_same_as_facet_ssim
            entry_date_facet_ssim
        ],
        "Concept" => %w[
            preflabel_tesim
        ],
        "ConceptScheme" => %w[
            preflabel_tesim
            description_tesim
        ],
        "Place" => %w[
            related_authority_tesim
            preflabel_tesim
            same_as_tesim
            inScheme_ssim
            place_name_tesim
            parent_ADM2_tesim
            parent_ADM1_tesim
            feature_code_tesim
        ],
        "Person" => %w[
            related_authority_tesim
            preflabel_tesim
            altlabel_tesim
            inScheme_ssim
            family_tesim
            given_name_tesim
            dates_tesim
            epithet_tesim
            dates_of_office_tesim
        ],
        "RelatedAgent" => %w[
            relatedAgentFor_ssim
            person_same_as_tesim
            person_group_tesim
            person_gender_tesim
            person_role_tesim
            person_descriptor_tesim
            person_same_as_facet_ssim
            person_same_as_new_tesim
            person_same_as_search
            person_role_facet_ssim
            person_role_new_tesim
            person_role_search
            person_descriptor_facet_ssim
            person_descriptor_new_tesim
            person_descriptor_search
            person_descriptor_as_written_search
        ],
        "RelatedPlace" => %w[
            relatedPlaceFor_ssim
            place_same_as_tesim
            place_as_written_tesim
            place_role_tesim
            place_as_written_search
            place_same_as_facet_ssim
            place_same_as_new_tesim
            place_same_as_search
            place_role_facet_ssim
            place_role_new_tesim
            place_role_search
        ],
        "SingleDate" => %w[
            dateFor_ssim
            date_tesim
            date_certainty_tesim
            date_type_tesim
            date_facet_ssim
        ],
        "EntryDate" => %w[
            entryDateFor_ssim
            date_role_tesim
            date_role_facet_ssim
            date_role_new_tesim
            date_role_search
        ],
        "OrderedCollection" => %w[
            preflabel_tesim
            description_tesim
            date_tesim
            coll_id_tesim
            date_facet_ssim
        ],
        "Image" => %w[
            hasTarget_ssim
            motivated_by_tesim
            file_path_tesim
        ],
        "Group" => %w[
            related_authority_tesim
            preflabel_tesim
            inScheme_ssim
            name_tesim
        ],
        "ActiveFedora::DirectContainer" => %w[
        ],
        "ActiveFedora::Aggregation::ListSource" => %w[
            ordered_targets_ssim
        ],
        "ActiveFedora::Aggregation::Proxy" => %w[
            proxyFor_ssim
        ],
        "ActiveFedora::IndirectContainer" => %w[
        ]
    }.freeze

    # bundle exec rake datachecker:compare_object[SOLR_URL1,SOLR_URL_2,OUTPUT_FILE_NAME]
    desc "Compare objects between 2 Solr instances"
    task :compare_object, [:solr1,:solr2,:output_file] => [:environment] do |t, args|
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

    # bundle exec rake datachecker:compare_fields[SOLR_URL1,SOLR_URL_2,OUTPUT_FILE_NAME]
    desc "Compare object fields between 2 Solr instances"
    task :compare_fields, [:solr1,:solr2,:output_file] => [:environment] do |t, args|
        solr1  = args[:solr1]
        solr2  = args[:solr2]
        o_file = args[:output_file]
        missing_objects  = []
        mismatches       = []
        errors           = []
        no_model_objects = []

        puts "Loading object ids from: #{solr1} ..."
        idlist1 = get_ids(solr1, false)

        puts "Loading object ids from: #{solr2} ..."
        idlist2 = get_ids(solr2, false)

        FIELDS_TO_CHECK.each do |model, fields_to_check|
            puts "checking model: #{model}"

            #For some models, nothing needs to be checked
            unless fields_to_check.present?
                puts "    EMPTY field list, bypass."
                next
            end
            solr_data1 = get_data_by_model(solr1, model)
            solr_data2 = get_data_by_model(solr2, model)

            solr_data1.each do |solr_object1|
                begin
                    id = solr_object1['id']
                    solr_object2_array = solr_data2.select{|o| o['id'] == id}
                    if solr_object2_array.nil? or solr_object2_array[0].nil?
                        missing_objects << id
                        next
                    end

                    solr_object2 = solr_object2_array[0]

                    unless solr_object1['has_model_ssim'].nil?
                        fields_to_check.each do |field|
                            # the following lines will remove prefixes in the id field
                            value1 = normalize_field_values(field, solr_object1[field])
                            value2 = normalize_field_values(field, solr_object2[field])

                            if solr_object1[field] != solr_object2[field]
                                mismatches << "Mismatch object: #{model},#{id},#{field},#{value1},#{value2}"
                            end
                        end
                    else
                        no_model_objects << id
                    end
                rescue Error => e
                    puts e
                    errors << "#{model} - #{id}"
                end
            end
        end

        puts "Generating reports..."
        puts "    missing objects"
        f1 = File.open(o_file + ".missing", "w")
        f1.puts missing_objects
        f1.close

        puts "    mismatch objects"
        f2 = File.open(o_file + ".mismatch", "w")
        f2.puts mismatches
        f2.close

        puts "    errors"
        f3 = File.open(o_file + ".errors", "w")
        f3.puts errors
        f3.close

        puts "    no_model_objects"
        f4 = File.open(o_file + ".no_model_objects", "w")
        f4.puts no_model_objects
        f4.close
    end


    private
        def get_ids(solr_url, with_model=true)
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
                    if doc['has_model_ssim'].nil?
                        ids << doc['id']
                    else
                        if with_model
                            ids << doc['has_model_ssim'][0] + ':' + doc['id']
                        else
                            ids << doc['id']
                        end
                    end
                end
            end
            ids
        end

        def get_data(solr_url, id)
            solr_query = "id:#{id}"
            solr = RSolr.connect :url => solr_url
            response = solr.get 'select', :params => {
                :q=>"#{solr_query}",
                :start=>0,
                :rows=>1,
                :wt=>'json'
            }
            number_of_objects = response['response']['numFound']
            if number_of_objects == 1
                response['response']['docs'][0]
            else
                '{}'
            end
        end

        # get data from solr by content model, RSOLR is not used here as some field are missing
        def get_data_by_model(solr_url, model)
            response = Faraday.get("#{solr_url}/select", {q: "has_model_ssim:#{model}", rows: 100000, wt: 'json'}, {'Accept' => 'application/json'})
            j = JSON.parse(response.body)
            number_of_objects = j['response']['numFound']
            if number_of_objects > 0
                j['response']['docs']
            else
                '[]'
            end
        end

        def normalize_field_values(field, values)
            normalize_field_values = field=='ordered_targets_ssim'? (values.collect {|x| get_id(x)}) : values
        end

        def get_id(o)
            id = (o.include? '/') ? o.rpartition('/').last : o
        end
end
