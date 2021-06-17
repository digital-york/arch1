module Ingest
    module DepartmentHelper

        # search department's id by the given department label
        # The prefix 's_' is the convention here, means retrieving data from Solr
        # Ingest::DepartmentHelper.s_get_department_id('C')
        def self.s_get_department_id(department_label)
            id = ''
            begin
                SolrQuery.new.solr_query("has_model_ssim:\"Department\" AND preflabel_tesim:\"#{department_label}\"")['response']['docs'].map do |r|
                    id = r['id']
                end
            rescue
            end
            id
        end

        # get all Series ids for a Department
        # Ingest::DepartmentHelper.s_get_series_ids(department_id)
        def self.s_get_series_ids(department_id)
            series_ids = []
            SolrQuery.new.solr_query("has_model_ssim:\"Series\" AND isPartOf_ssim:\"#{department_id}\"")['response']['docs'].map do |r|
                series_ids << r['id']
            end
            series_ids
        end

        def self.s_get_department_id_from_desc(department_desc)
            id = ''
            begin
                query = "has_model_ssim:\"Department\" AND description_tesim:\"#{department_desc}\""
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    id = r['id']
                end
            rescue
            end
            id
        end

        # Ingest::DepartmentHelper.create_department('C','Chancery')
        def self.create_department(department_label, department_desc)

            existing_department_id = Ingest::DepartmentHelper.s_get_department_id(department_label)
            unless existing_department_id.blank?
                puts '  Found department: ' + existing_department_id
                return Department.find(existing_department_id)
            end

            d = Department.new
            d.rdftype = d.add_rdf_types
            d.preflabel = department_label
            d.description = department_desc

            d.save
            puts '  Created department: ' + d.id

            d
        end
    end
end