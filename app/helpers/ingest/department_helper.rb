module Ingest
    module DepartmentHelper

        # search department's id by the given department label
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_department_id(department_label)
            ids = []
            begin
                SolrQuery.new.solr_query("has_model_ssim:\"Department\" AND preflabel_tesim:\"#{department_label}\"")['response']['docs'].map do |r|
                    ids = r['id']
                end
            rescue
            end
            ids
        end

        # Ingest::DepartmentHelper.create_department('Test Series')
        def self.create_department(department_label, department_desc)
            d = Department.new
            d.rdftype = d.add_rdf_types
            d.preflabel = department_label
            d.description = department_desc

            d.save

            d
        end
end