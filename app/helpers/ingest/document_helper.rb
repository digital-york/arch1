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

            place_of_datings = []
            place_of_dating_descs = Ingest::ExcelHelper.extract_places_info(place_of_dating, 'place of dating', '')
            place_of_dating_descs.each do |place_of_dating_desc|
                place_authority_ids = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                    place_of_dating_desc.place_name,
                    place_of_dating_desc.county,
                    place_of_dating_desc.country)
                if place_authority_ids.blank?
                    puts 'Place of dating Error: cannot find place_authority id'
                    puts ">>> #{reference}..."
                    return
                elsif place_authority_ids.length()!=1
                    puts 'Place of dating Error: returns more than 1 places.'
                    puts ">>> #{reference}..."
                    puts place_authority_ids
                    return
                end
                place_of_dating = Ingest::PlaceOfDatingHelper.create_place_of_dating(place_of_dating_desc.place_as_written,
                                                                                     place_authority_ids[0],
                                                                                     ['place of dating'])
                place_of_datings << place_of_dating
            end
            d.place_of_datings = place_of_datings

            # d.addressee = addressee
            # d.sender = sender
            # d.person = person
            unless place.blank?
                tna_place_authority_ids = []
                place_descs = extract_places_info(place, '', '')
                place_descs.each do |place_desc|
                    place_ids = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                        place_desc.place_name,
                        place_desc.county,
                        place_desc.country)
                    if place_ids.blank?
                        puts 'Place(s) Error: cannot find place_authority id'
                        puts ">>> #{reference}..."
                        return
                    elsif place_ids.length()!=1
                        puts 'Place(s) Error: returns more than 1 places.'
                        puts ">>> #{reference}..."
                        return
                    end

                    tna_place_authority_id = Ingest::TnaPlaceHelper.create_tna_place(
                        place_desc.place_as_written,
                        place_desc.place_ids[0],
                        [])
                    tna_place_authority_ids << tna_place_authority_id
                end
                d.place = tna_place_authority_ids
            end

            d.save
            puts "  Created/updated Document: #{d.id}" unless d.nil?
            log.info "  Created/updated Document: #{d.id}" unless d.nil?
            d
        end
    end
end