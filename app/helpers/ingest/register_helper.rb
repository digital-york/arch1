module Ingest
    module RegisterHelper
        # search registers' ids by the given label
        # make sure to check the returned array
        # normally it should only return 1 element
        def self.get_register_ids(register_name)
            id = nil
            SolrQuery.new.solr_query("preflabel_tesim:\"#{register_name}\"")['response']['docs'].map do |r|
                id = r['id']
            end
        end
    end
end