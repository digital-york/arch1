module Ingest
    module SeriesHelper
        # search series' id by the given document reference
        # The prefix 's_' is the convention here, means retrieving data from Solr
        # Ingest::SeriesHelper.s_get_series_id('6108vp64c', 'C1')
        def self.s_get_series_id(department_id, series_label)
            id = ''
            begin
                SolrQuery.new.solr_query("has_model_ssim:\"Series\" AND preflabel_tesim:\"#{series_label}\" AND isPartOf_ssim:\"#{department_id}\"")['response']['docs'].map do |r|
                    id = r['id']
                end
            rescue
            end
            id
        end

        # get all document ids within a series
        def self.s_get_all_document_ids(series_id)
            document_ids = []

            unless series_id.nil?
                query = "has_model_ssim:Document AND series_ssim:#{series_id}"
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    document_ids << r['id']
                end
            end

            document_ids
        end

        # Nb: the second params is the full series string, e.g. C85 - Significations of Excommunication
        def self.s_get_series_id_from_desc(department_id, series_string)
            id = ''
            series_label = series_string.split('-')[0].gsub(/\s+/, "")
            series_desc = series_string.split('-')[1].strip
            begin
                query = "has_model_ssim:\"Series\" AND preflabel_tesim:\"#{series_label}\" description_tesim:\"#{series_desc}\" AND isPartOf_ssim:\"#{department_id}\""
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    id = r['id']
                end
            rescue
            end
            id
        end

        def self.s_get_series_id_from_label(series_label)
            id = ''
            begin
                query = "has_model_ssim:\"Series\" AND preflabel_tesim:\"#{series_label}\""
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    id = r['id']
                end
            rescue
            end
            id
        end

        # Ingest::SeriesHelper.create_series('C1', 'Early Chancery Proceedings', '6108vp64c')
        def self.create_series(series_label, series_desc, department_id)
            # trying to find if the series has been created first
            s_id = Ingest::SeriesHelper.s_get_series_id(department_id, series_label)

            return Series.find(s_id) unless s_id.blank?

            s = Series.new
            s.rdftype = s.add_rdf_types
            s.preflabel = series_label
            s.description = series_desc
            s.department = Department.find(department_id)

            s.save
            s
        end
    end
end