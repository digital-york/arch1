module Ingest
    module EntryDateHelper
        # search date type id by the given label
        # The prefix 's_' is the convention here, means retrieving data from Solr
        # e.g.
        # pry(main)> Ingest::EntryDateHelper.s_get_date_role_id('birth date')
        # => "db78tf37d"
        def self.s_get_date_role_id(date_role_label)
            date_role_id = nil

            response = SolrQuery.new.solr_query('has_model_ssim:"Concept" AND preflabel_tesim:"' + date_role_label + '"', 'id,preflabel_tesim')

            response['response']['docs'].map do |pobj|
                if pobj['preflabel_tesim'][0].to_s.downcase == date_role_label.downcase
                    date_role_id = pobj['id']
                end
            end

            date_role_id
        end

        # Ingest::EntryDateHelper.create_single_date
        def self.create_single_date(entry_date, date, certainties, date_type)
            sd = SingleDate.new

            sd.rdftype        = sd.add_rdf_types
            sd.date           = date
            sd.date_certainty = [certainties] unless certainties.blank?
            sd.date_type      = date_type
            sd.entry_date     = entry_date
            sd.save
            entry_date.single_dates << sd
            entry_date.save

            sd
        end

        # Ingest::EntryDateHelper.create_entry_date
        def self.create_entry_date(date_role, note)
            ed = EntryDate.new

            ed.rdftype      = ed.add_rdf_types
            ed.date_role    = self.s_get_date_role_id(date_role)
            ed.date_note    = note
            ed.save

            ed
        end
    end
end