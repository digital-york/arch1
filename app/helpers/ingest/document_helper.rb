require 'logger'

module Ingest
    module DocumentHelper
        # search department's id by the given document reference
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_department_label(document_reference)
            reference.split(' ')[0]
        end

        # search series's id by the given document reference
        def self.s_get_series_label(document_reference)
            reference.split('/')[0].gsub(" ", "")
        end

        # find Document by series id and reference.
        # pry(main)> Ingest::DocumentHelper.s_find_document('1257b485h', 'C 81/1786/43')
        # => "2b88qc56f"
        def self.s_find_document(series_id, reference)
            document_id = nil

            unless series_id.nil? or reference.nil?
                query = "has_model_ssim:Document AND series_ssim:#{series_id} AND reference_tesim:\"#{reference}\""
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    document_id = r['id']
                end
            end

            document_id
        end

        # Ingest::DocumentHelper.create_document
        def self.create_or_update_document(
            allow_edit,
            repository,
            series_id,
            reference,
            publication,
            summary,
            entry_date_note,
            note,
            document_type,
            date_of_document,
            place_of_dating,
            language,
            subject,
            addressee,
            sender,
            person,
            place)
            log = Logger.new "log/document_helper.log"

            document_id = s_find_document(series_id, reference)

            if document_id.nil?
                d = Document.new
            else
                d = Document.find(document_id)
                puts '  found document ' + document_id
                log.info '  found document ' + document_id
                if allow_edit==false
                    return d
                end
            end

            d.repository = repository
            # add document rdf types
            d.rdftype = d.add_rdf_types
            # link document to Series
            d.series = Series.find(series_id)
            d.reference = reference
            d.publication = publication
            d.summary = summary
            d.entry_date_note = entry_date_note
            d.note = note
            d.document_type = document_type

            # d.date_of_document = date_of_document

            d.language = Ingest::AuthorityHelper.s_get_language_object_ids(language) unless language.blank?
            d.subject = subject unless subject.blank?
            # d.place_of_dating = place_of_dating
            # d.addressee = addressee
            # d.sender = sender
            # d.person = person
            # d.place = place

            d.save
            puts "  Created/updated Document: #{d.id}" unless d.nil?
            log.info "  Created/updated Document: #{d.id}" unless d.nil?
            d
        end
    end
end