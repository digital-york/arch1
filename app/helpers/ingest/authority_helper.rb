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

        # find language object ids from label
        # input: languages as array, e.g. ['English']
        # output: language object ids, e.g. ['xxxxxx']
        # e.g.
        # [1] pry(main)> Ingest::AuthorityHelper.s_get_language_object_ids(['English','Latin'])
        # => ["w37636771", "pz50gw105"]
        def self.s_get_language_object_ids(languages)
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

        # find section_types object ids from label
        # input: section_types as array, e.g. ["diverse letters"]
        # output: section type object ids, e.g. ['xxxxxx']
        # e.g.
        # [1] pry(main)> Ingest::AuthorityHelper.s_get_section_type_object_ids(['diverse letters'])
        # => ["j6731378s"]
        def self.s_get_section_type_object_ids(section_types)
            section_type_ids = []
            section_types.each do |sect|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"section_types"', 'id')
                response['response']['docs'].map do |s|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + s['id'] + '" AND preflabel_tesim:"' + sect.to_s.downcase + '"', 'id')
                    resp['response']['docs'].map do |se|
                        section_type_ids += [se['id']]
                    end
                end
            end
            section_type_ids
        end

        # find entry_types object ids from label
        # input: entry_types as array, e.g. ["Deputation", "Commission"]
        # output: entry type object ids, e.g. ['xxxxxx']
        # e.g.
        # [1] pry(main)> Ingest::AuthorityHelper.s_get_entry_type_object_ids(["Deputation")
        # => ["j6731378s"]
        def self.s_get_entry_type_object_ids(entry_types)
            entry_type_ids = []
            entry_types.each do |entry_type|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"entry_types"', 'id')
                response['response']['docs'].map do |s|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + s['id'] + '" AND preflabel_tesim:"' + entry_type.to_s.downcase + '"', 'id,preflabel_tesim')
                    resp['response']['docs'].map do |se|
                        # doing an exact match of the search term
                        if se['preflabel_tesim'][0].to_s.downcase == entry_type.downcase
                            entry_type_ids += [se['id']]
                        end
                    end
                end
            end
            entry_type_ids
        end

        # Find subject ids by its texts
        # [2] pry(main)> Ingest::AuthorityHelper.s_get_subject_object_ids(['Prioresses'])
        # => ["zs25xc64x"]
        def self.s_get_subject_object_ids(subject_texts)
            subject_ids = []
            subject_texts.each do |subject_text|
                subject_id = s_get_subject_object_id(subject_text)
                subject_ids << subject_id unless subject_id.nil?
            end
            subject_ids
        end

        # Find subject id by its text
        # [2] pry(main)> Ingest::AuthorityHelper.s_get_subject_object_id('Prioresses')
        # => "zs25xc64x"
        def self.s_get_subject_object_id(subject_text)
            Terms::SubjectTerms.new('subauthority').find_id_with_alts(subject_text)
        end

        # find place object ids from label
        # input: places as array, e.g. ['Yarm, North Riding of Yorkshire, England']
        # output: place object ids, e.g. ['xxxxxx']
        # e.g.
        # pry(main)> Ingest::AuthorityHelper.s_get_place_object_ids(['Yarm, North Riding of Yorkshire, England'])
        # => ["1c18df984"]
        def self.s_get_place_object_ids(places)
            places_ids = []
            places.each do |place|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"places"', 'id')
                # first, query ConceptSchema for places
                response['response']['docs'].map do |l|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + l['id'] + '" AND preflabel_tesim:"' + place.downcase + '"', 'id')
                    resp['response']['docs'].map do |p|
                        places_ids += [p['id']]
                    end
                end
            end
            places_ids
        end

        # find people object ids from label
        # input: people name as array, e.g. ['Normavell, Eleanor, fl 1539-1540, Prioress of Nun Appleton']
        # output: people object ids, e.g. ['xxxxxx']
        # e.g.
        # pry(main)> Ingest::AuthorityHelper.s_get_people_object_ids(['Normavell, Eleanor, fl 1539-1540, Prioress of Nun Appleton'])
        # => ["1c18df79x"]
        def self.s_get_people_object_ids(people)
            people_ids = []
            people.each do |p|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"people"', 'id')
                # first, query ConceptSchema for people
                response['response']['docs'].map do |l|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + l['id'] + '" AND preflabel_tesim:"' + p.downcase + '"', 'id')
                    resp['response']['docs'].map do |pobj|
                        people_ids += [pobj['id']]
                    end
                end
            end
            people_ids
        end

    end
end