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

        # get all Folio ids for a Register
        # Ingest::RegisterHelper.s_get_folio_ids(Register ID)
        def self.s_get_folio_ids(register_id)
            folio_ids = []
            SolrQuery.new.solr_query("has_model_ssim:\"Folio\" AND isPartOf_ssim:\"#{register_id}\"")['response']['docs'].map do |r|
                folio_ids << r['id']
            end
            folio_ids
        end

        # create a new register
        # return the newly created register
        # e.g.
        #   Ingest::RegisterHelper.create_register('Test register', 'Test register','9z903019d', 'https://dlib.york.ac.uk/yodl/api/resource/york:799266/assets/thumbnail.jpg')
        #
        # TO INVESTIGATE: register_id/list_source
        #
        #
        def self.create_register(pref_label, reg_id, ordered_collection_id, thumbnail_url)
            r = Register.new
            r.rdftype               = r.add_rdf_types
            r.preflabel             = pref_label
            r.reg_id                = reg_id
            r.thumbnail_url         = thumbnail_url
            r.ordered_collection    = OrderedCollection.find(ordered_collection_id)

            r.save

            r
        end
    end
end