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
                        language_ids << la['id']
                    end
                end
            end
            language_ids
        end

        # find language object labels from ids
        # input: language ids as array, e.g. ['xxxxxx']
        # output: language object labels, e.g. ['English']
        # e.g.
        # pry(main)> Ingest::AuthorityHelper.s_get_language_labels(['pz50gw105'])
        # => ["Latin"]
        def self.s_get_language_labels(language_ids)
            language_labels = []
            language_ids.each do |l_id|
                resp = SolrQuery.new.solr_query('id:' + l_id, 'id,preflabel_tesim')
                resp['response']['docs'].map do |la|
                    language_labels << la['preflabel_tesim'][0]
                end
            end
            language_labels
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
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + s['id'] + '" AND preflabel_tesim:"' + sect.to_s.downcase + '"', 'id,preflabel_tesim')
                    resp['response']['docs'].map do |se|
                        # doing an exact match of the search term
                        if se['preflabel_tesim'][0].to_s.downcase == sect.to_s.downcase
                            section_type_ids << se['id']
                        end
                    end
                end
            end
            section_type_ids
        end

        # find section_types labels from ids
        # input: section_type ids as array
        # output: section type labels
        # e.g.
        # pry(main)> Ingest::AuthorityHelper.s_get_section_type_labels(['sb397b875'])
        # => ["Diverse jurisdictions"]
        def self.s_get_section_type_labels(section_type_ids)
            section_type_labels = []
            return section_type_labels if section_type_ids.blank?
            section_type_ids.each do |section_type_id|
                resp = SolrQuery.new.solr_query('id:' + section_type_id, 'id,preflabel_tesim')
                resp['response']['docs'].map do |se|
                    section_type_labels << se['preflabel_tesim'][0]
                end
            end
            section_type_labels
        end

        # find entry_types object ids from label
        # input: entry_types as array, e.g. ["Deputation", "Commission"]
        # output: entry type object ids, e.g. ['xxxxxx']
        # e.g.
        # [1] pry(main)> Ingest::AuthorityHelper.s_get_entry_type_object_ids(["Deputation")
        # => ["j6731378s"]
        def self.s_get_entry_type_object_ids(entry_types)
            entry_type_ids = []
            return entry_type_ids if entry_types.nil?

            entry_types.each do |entry_type|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"entry_types"', 'id')
                response['response']['docs'].map do |s|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + s['id'] + '" AND preflabel_tesim:"' + entry_type.to_s.downcase + '"', 'id,preflabel_tesim')
                    resp['response']['docs'].map do |se|
                        # doing an exact match of the search term
                        if se['preflabel_tesim'][0].to_s.downcase == entry_type.downcase
                            entry_type_ids << se['id']
                        end
                    end
                end
            end
            entry_type_ids
        end

        # find entry_type labels from ids
        # input: entry_type ids as array, e.g. ["s1784k73d","1j92g746t"]
        # output: entry type labels, e.g. ['Mandate','Induction']
        # e.g.
        # [1] pry(main)> Ingest::AuthorityHelper.s_get_entry_type_labels(["s1784k73d","1j92g746t"])
        # => ["j6731378s"]
        def self.s_get_entry_type_labels(entry_type_ids)
            entry_type_labels = []
            return entry_type_labels if entry_type_ids.blank?

            entry_type_ids.each do |entry_type_id|
                resp = SolrQuery.new.solr_query('id:' + entry_type_id, 'id,preflabel_tesim')
                resp['response']['docs'].map do |et|
                    entry_type_labels << et['preflabel_tesim'][0]
                end
            end
            entry_type_labels
        end

        # Find subject ids by its texts
        # [2] pry(main)> Ingest::AuthorityHelper.s_get_subject_object_ids(['Prioresses'])
        # => ["zs25xc64x"]
        def self.s_get_subject_object_ids(subject_texts)
            subject_ids = []
            subject_texts.each do |subject_text|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"Borthwick Institute for Archives Subject Headings for the Archbishops\' Registers"', 'id')
                response['response']['docs'].map do |s|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + s['id'] + '" AND preflabel_tesim:"' + subject_text.downcase + '"', 'id,preflabel_tesim')
                    resp['response']['docs'].map do |se|
                        # doing an exact match of the search term
                        if se['preflabel_tesim'][0].to_s.downcase == subject_text.downcase
                            subject_ids << se['id']
                        end
                    end
                end
            end
            subject_ids
        end

        # Find subject texts by its ids
        # Ingest::AuthorityHelper.s_get_subject_labels(['zs25xc64x'])
        def self.s_get_subject_labels(subject_ids)
            subject_labels = []
            subject_ids.each do |subject_id|
                resp = SolrQuery.new.solr_query('id:' + subject_id, 'id,preflabel_tesim')
                resp['response']['docs'].map do |sj|
                    subject_labels << sj['preflabel_tesim'][0]
                end
            end
            subject_labels
        end

        # find place object ids from label
        # input: places as array, e.g. ['Yarm, North Riding of Yorkshire, England']
        # output: place object ids, e.g. ['xxxxxx']
        # e.g.
        # pry(main)> Ingest::AuthorityHelper.s_get_place_object_id('Yarm, North Riding of Yorkshire, England')
        # => "1c18df984"
        def self.s_get_place_object_id(place)
            return '' if place.blank?

            places_id = ''

            response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"places"', 'id')
            # first, query ConceptSchema for places
            response['response']['docs'].map do |l|
                # Due to the mismatches of the authority being used in spreadsheet and
                # the editing tool, e.g.
                # 'Cawood' in spreadsheet and
                # 'Cawood, West Riding of Yorkshire, England' in editing tool
                #
                # firstly, do a exact search
                #
                # DONOT use inScheme_ssim to find Place is NOT always working, e.g. Place: 5q47rn940 doesn't have this field
                # to refactor later: use has_model_ssim:Place
                resp = SolrQuery.new.solr_query('has_model_ssim:Place AND place_name_tesim:"' + place.downcase + '"', 'id,place_name_tesim,preflabel_tesim')
                resp['response']['docs'].map do |p|
                    if p['place_name_tesim'][0].to_s.downcase == place.downcase
                        places_id = p['id']
                    end
                end
                # Then, if places_id is not found, do a substring search
                if places_id.blank?
                    resp = SolrQuery.new.solr_query('has_model_ssim:Place AND place_name_tesim:' + place.downcase, 'id,place_name_tesim,preflabel_tesim')
                    resp['response']['docs'].map do |p|
                        places_id = p['id']
                    end
                end
            end

            places_id
        end

        # find place object ids from Place name, county, and country
        # input: place name, county, country, e.g.
        # 'Yarm, 'North Riding of Yorkshire', 'England'
        # output: place object ids, e.g. ['xxxxxx']
        # For example
        # pry(main)> Ingest::AuthorityHelper.s_get_exact_match_place_object_id('Yarm', 'North Riding of Yorkshire', 'England')
        # => "1c18df984"
        def self.s_get_exact_match_place_object_id(place_name, county, country)
            # From Jonathans's email on 21 May:
            # Many are in the system, but counties haven't been assigned consistently
            # (prebends were often associated with places in different counties to the one
            # where the cathedral or minster church lay, and some currently have the
            # county of the place and others have the county of the cathedral),
            # so I will need to agree a standard with Helen and go from there.
            # I will make sure they all match the main name given in the tool ('X Cathedral, Y prebend'),
            # and there shouldn't be any duplicates, so perhaps,
            # if you can tell your code not to look for a county if the word 'prebend' appears within a name,
            # that might cover everything?
            #
            # updated notes 05 Aug 2021: The whole 'X Cathedral, Y prebend' is the place name
            # e.g. 'prebend' isn't part of the county

            # return '' if place_name.blank? or county.blank?
            return '' if place_name.blank?

            place_ids = []

            q = "has_model_ssim:Place"     # place authority
            q += " AND place_name_tesim:\"#{place_name.downcase}\""  # place name
            # ignore county if ' prebend' is include as it won't return duplicates
            unless county.blank?
                q += " AND parent_ADM2_tesim:\"#{county.downcase}\"" # county
            end
            q += " AND parent_ADM1_tesim:\"#{country.downcase}\"" unless country.blank? # country
            resp = SolrQuery.new.solr_query(q, 'id,place_name_tesim,preflabel_tesim', 1000, 'system_modified_dtsi desc')
            resp['response']['docs'].map do |p|
                if p['place_name_tesim'][0].downcase == place_name.downcase
                    place_ids << p['id']
                end
            end

            place_ids
        end

        # get place object name from object_id
        # pry(main)> Ingest::AuthorityHelper.s_get_place_name('9s1616342')
        # => ["Kirkham"]
        def self.s_get_place_name(place_object_id)
            place_name = ''
            resp = SolrQuery.new.solr_query('id:' + place_object_id, 'id,place_name_tesim')
            resp['response']['docs'].map do |p|
                place_name = p['place_name_tesim']
            end
            place_name
        end

        # get place role object label from place_role_id
        # pry(main)> Ingest::AuthorityHelper.s_get_place_role_name('37720c723')
        # => ["place of dating"]
        def self.s_get_place_role_name(place_role_id)
            place_role_name = ''
            resp = SolrQuery.new.solr_query('id:' + place_role_id, 'id,preflabel_tesim')
            resp['response']['docs'].map do |p|
                place_role_name = p['preflabel_tesim']
            end
            place_role_name
        end

        # get place type name from place_type object id
        # pry(main)> Ingest::AuthorityHelper.s_get_place_type_name('02870z61f')
        # => ["none given"]
        def self.s_get_place_type_name(place_type_id)
            place_type_name = ''
            resp = SolrQuery.new.solr_query('id:' + place_type_id, 'id,preflabel_tesim')
            resp['response']['docs'].map do |p|
                place_type_name = p['preflabel_tesim']
            end
            place_type_name
        end

        # find place role ids from label
        # input: place roles as array, e.g. ['place of dating']
        # output: place role object ids, e.g. ['xxxxxx']
        # e.g.
        # pry(main)> Ingest::AuthorityHelper.s_get_place_role_ids(['place of dating'])
        # => [""]
        def self.s_get_place_role_ids(place_roles)
            places_role_ids = []
            place_roles.each do |place_role|
                # first, query ConceptSchema for place_types
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"place_roles"', 'id')

                response['response']['docs'].map do |l|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + l['id'] + '" AND preflabel_tesim:"' + place_role.downcase + '"', 'id,preflabel_tesim')
                    resp['response']['docs'].map do |p|
                        if p['preflabel_tesim'][0].to_s.downcase == place_role.downcase
                            places_role_ids << p['id']
                        end
                    end
                end
            end
            places_role_ids
        end

        # find place type ids from label
        # input: place types as array, e.g. ['none given']
        # output: place object ids, e.g. ['xxxxxx']
        # e.g.
        # pry(main)> Ingest::AuthorityHelper.s_get_place_type_ids(['none given'])
        # => ["02870z61f"]
        def self.s_get_place_type_ids(place_types)
            places_type_ids = []
            place_types.each do |place_type|
                # first, query ConceptSchema for place_types
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"place_types"', 'id')

                response['response']['docs'].map do |l|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + l['id'] + '" AND preflabel_tesim:"' + place_type.downcase + '"', 'id,preflabel_tesim')
                    resp['response']['docs'].map do |p|
                        if p['preflabel_tesim'][0].to_s.downcase == place_type.downcase
                            places_type_ids << p['id']
                        end
                    end
                end
            end
            places_type_ids
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
                        people_ids << pobj['id']
                    end
                end
            end
            people_ids
        end

    end
end