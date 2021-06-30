module Ingest
    module DocumentDateHelper

        # Ingest::DocumentDateHelper.create_single_date
        def self.create_single_date(document_date, date, certainties, date_type)
            sd = SingleDate.new

            sd.rdftype        = sd.add_rdf_types
            sd.date           = date unless date.blank?
            sd.date_certainty = [certainties] unless certainties.blank?
            sd.date_type      = date_type
            sd.document_date  = document_date
            sd.save
            document_date.single_dates << sd
            document_date.save

            sd
        end

        # Ingest::DocumentDateHelper.create_document_date
        #
        def self.create_document_date(document_id, date_role, note)
            dd = DocumentDate.new

            dd.rdftype = dd.add_rdf_types
            # the TNA spreadsheet doesn't have date_role
            # dd.date_role    = self.s_get_date_role_id(date_role) unless date_role.blank?
            dd.date_note = note.join unless note.blank?
            dd.document_id = document_id unless document_id.blank?
            dd.save

            dd
        end

        # get document_date_id from entry_id, date_role, and note
        # pry(main)> Ingest::DocumentDateHelper.s_get_document_date_ids('j098zp686', nil, 'Entry date note test')
        # => ["8g84mn23z"]
        def self.s_get_document_date_ids(document_id, date_role, note)
            document_date_ids = []
            query = 'has_model_ssim:"DocumentDate" AND documentDateFor_ssim:"'+document_id+'"'
            unless date_role.blank?
                query += ' AND date_role_search:"' + date_role + '"'
            end
            unless note.blank?
                query += ' AND date_note_tesim:"'+note+'"'
            end
            response = SolrQuery.new.solr_query(query, 'id')
            response['response']['docs'].map do |pobj|
                document_date_ids << pobj['id']
            end
            document_date_ids
        end

        # get single_date_id from document_date_id, date, certainty, date_type
        # Ingest::DocumentDateHelper.s_get_single_date_ids('5999ng12x')
        def self.s_get_single_date_ids(document_date_id, date=nil, certainty=nil, date_type=nil)
            single_date_ids = []
            return single_date_ids if document_date_id.blank?

            query = 'has_model_ssim:"SingleDate" AND dateFor_ssim:"'+document_date_id+'"'
            query = query + ' AND date_tesim:"' + date + '"' unless date.blank?
            query = query + ' AND date_certainty_tesim:"' + certainty + '"' unless certainty.blank?
            query = query + ' AND date_type_tesim:"' + date_type + '"' unless date_type.blank?

            response = SolrQuery.new.solr_query(query, 'id')
            response['response']['docs'].map do |pobj|
                single_date_ids << pobj['id']
            end
            single_date_ids
        end
    end
end