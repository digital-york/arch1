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
        # [1] pry(main)> Ingest::AuthorityHelper.s_get_language_object_id(['English','Latin'])
        # => ["w37636771", "pz50gw105"]
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

        # find section_types object ids from label
        # input: section_types as array, e.g. ["diverse letters"]
        # output: section type object ids, e.g. ['xxxxxx']
        # e.g.
        # [1] pry(main)> Ingest::AuthorityHelper.s_get_section_type_object_id(['diverse letters'])
        # => ["j6731378s"]
        def self.s_get_section_type_object_id(section_types)
            section_type_ids = []
            section_types.each do |sect|
                response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"section_types"', 'id')
                response['response']['docs'].map do |s|
                    resp = SolrQuery.new.solr_query('inScheme_ssim:"' + s['id'] + '" AND preflabel_tesim:"' + sect.downcase + '"', 'id')
                    resp['response']['docs'].map do |se|
                        section_type_ids += [se['id']]
                    end
                end
            end
            section_type_ids
        end

        # Find subject id by its text
        # [2] pry(main)> Ingest::AuthorityHelper.s_get_subject_object_id('Prioresses')
        # => "zs25xc64x"
        def self.s_get_subject_object_id(subject_text)
            Terms::SubjectTerms.new('subauthority').find_id_with_alts(subject_text)
        end



    end
end