module Ingest
    module FolioHelper
        # search folio's id by the given label
        # make sure to check the returned array
        # normally it should only return 1 element
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_folio_ids(folio_label)
            ids = nil
            SolrQuery.new.solr_query("has_model_ssim:\"Folio\" AND preflabel_tesim:\"#{folio_label}\"")['response']['docs'].map do |r|
                ids = r['id']
            end
        end

        # get all Entry ids for a Folio
        def self.s_get_entry_ids(folio_id)
            ids = nil
            SolrQuery.new.solr_query("has_model_ssim:\"Entry\" AND folio_ssim:\"#{folio_id}\"")['response']['docs'].map do |r|
                ids = r['id']
            end
        end

        # get archbishop register folio id
        # input: register, folio, side
        # returns folio id
        def self.s_get_ar_folio_id(register_name, folio_number, folio_side)
            prefix = 'Abp'
            id = nil
            # Convert folio info from:
            #   Register 7	132	(verso)
            # to:
            #   Abp Reg 7 f.132 (recto)
            folio_label = "#{prefix} #{register_name.gsub('Register', 'Reg')} f.#{folio_number} #{folio_side}"
            SolrQuery.new.solr_query("preflabel_tesim:\"#{folio_label}\"",'id,preflabel_tesim')['response']['docs'].map do |r|
                if r['preflabel_tesim'][0].downcase == folio_label.downcase
                    id = r['id']
                end
            end
            id
        end

        # Ingest::FolioHelper.create_folio('Test Folio', 'ks65hc48h')
        def self.create_folio(pref_label, register_id)
            f = Folio.new
            f.rdftype               = f.add_rdf_types
            f.preflabel             = pref_label
            f.register              = Register.find(register_id)

            f.save

            f
        end
    end
end