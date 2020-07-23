module Ingest
    module EntryDateHelper
        # search date type id by the given label
        # The prefix 's_' is the convention here, means retrieving data from Solr
        # e.g.
        # pry(main)> Ingest::EntryDateHelper.s_get_date_role_ids(['birth date'])
        # => ["db78tf37d"]
        def self.s_get_date_role_ids(date_role_labels)
            date_role_ids = []
            date_role_labels.each do |dr|
                response = SolrQuery.new.solr_query('has_model_ssim:"Concept" AND preflabel_tesim:"'+dr+'"', 'id')

                response['response']['docs'].map do |pobj|
                    date_role_ids += [pobj['id']]
                end
            end
            date_role_ids
        end

        # Ingest::EntryDateHelper.create_single_date
        def self.create_single_date(entry_date_id, date, certainties, date_type)
            sd = SingleDate.new

            sd.rdftype    = sd.add_rdf_types
            sd.date       = date
            sd.certainty  = certainties
            sd.date_type  = date_type
            entry_date    = EntryDate.find(entry_date_id)
            sd.entry_date = entry_date
            sd.save
            entry_date.single_dates += sd
            entry_date.save

            sd
        end
    end
end