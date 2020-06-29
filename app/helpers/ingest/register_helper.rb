module Ingest
    module RegisterHelper
        # search registers' ids by the given label
        # make sure to check the returned array
        # normally it should only return 1 element
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_register_ids(register_name)
            ids = nil
            SolrQuery.new.solr_query("has_model_ssim:\"Register\" AND preflabel_tesim:\"#{register_name}\"")['response']['docs'].map do |r|
                ids = r['id']
            end
        end
    end
end