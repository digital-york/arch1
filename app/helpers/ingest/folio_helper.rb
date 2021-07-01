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
        # def self.s_get_entry_ids(folio_id)
        #     ids = nil
        #     SolrQuery.new.solr_query("has_model_ssim:\"Entry\" AND folio_ssim:\"#{folio_id}\"")['response']['docs'].map do |r|
        #         ids = r['id']
        #     end
        #     ids
        # end

        # return all containing entry ids for a folio
        def self.s_get_all_entry_ids(folio_id)
            entry_ids = []

            unless folio_id.nil?
                query = "has_model_ssim:Entry AND folio_ssim:#{folio_id}"
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    entry_ids << r['id']
                end
            end

            entry_ids
        end

        # get archbishop register folio id
        # input: register, folio, side, image_id
        # returns folio id
        def self.s_get_ar_folio_id(register_name, folio_number, folio_side, image_id)
            prefix = 'Abp'
            id = nil
            # Convert folio info from:
            #   Register 7	132	(verso)
            # to:
            #   Abp Reg 7 f.132 (recto)
            folio_label = "#{prefix} #{register_name.gsub('Register', 'Reg')} f.#{folio_number} #{folio_side}"
            solr_query = SolrQuery.new.solr_query("preflabel_tesim:\"#{folio_label}\"",'id,preflabel_tesim')
            if solr_query['response']['numFound'].to_i > 1 and (not image_id.blank?)
                # Perform second query to identify the folio id
                # has_model_ssim:Image and hasTarget_ssim:z316q346z and
                # file_path_tesim:Abp_Reg_07_0315
                solr_query['response']['docs'].map do |r|
                    folio_id = r['id']
                    second_query = "has_model_ssim:Image and hasTarget_ssim:#{folio_id} and file_path_tesim:#{image_id}"
                    solr_query2 = SolrQuery.new.solr_query(second_query,'id,preflabel_tesim')
                    # If the matched Image object can be found, return the folio_id
                    if solr_query2['response']['numFound'].to_i >= 1
                        id = folio_id
                    end
                end
            else
                solr_query['response']['docs'].map do |r|
                    if r['preflabel_tesim'][0].downcase == folio_label.downcase
                        id = r['id']
                    end
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

        # Return folio's label
        # Ingest::FolioHelper.get_folio_label('1c18df88w')
        def self.get_folio_label(folio_id)
            folio_query_result = SolrQuery.new.solr_query("id:\"#{folio_id}\"",'id,preflabel_tesim,isPartOf_ssim')['response']['docs'][0]
            folio_query_result['preflabel_tesim'][0]
        end

        # Get next folio label
        def self.get_next_folio_label(folio_label)
            if folio_label.include? "recto"
                return folio_label.gsub('recto', 'verso')
            end
            folio_label.split('.')[0] + '.' + (folio_label.split('.')[1].gsub(/[^0-9]/, '').to_i+1).to_s + ' (recto)'
        end
    end
end