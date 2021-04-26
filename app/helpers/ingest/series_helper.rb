module Ingest
    module SeriesHelper
        # search series' id by the given document reference
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_series_id(document_reference)
            ids = []
            begin
                series_name = document_reference.split('/')[0].split(' ')[1]
                SolrQuery.new.solr_query("has_model_ssim:\"Series\" AND preflabel_tesim:\"#{series_name}\"")['response']['docs'].map do |r|
                    ids = r['id']
                end
            rescue
            end
            ids
        end

        # Ingest::SeriesHelper.create_series('Test Series', 'xx')
        def self.create_folio(series_label, series_desc, department_id)
            s = Series.new
            s.rdftype = s.add_rdf_types
            s.preflabel = series_label
            s.descritipn = series_desc
            s.department = Department.find(department_id)

            s.save

            s
        end
end