require 'logger'

module Validator
    # This class validate TNA document
    class TnaValidator

        # if mismatch found, return first mismatched field name as string
        # else return empty string
        def self.validate_document(tna_document_row)
            log = Logger.new "log/tna_document_validator.log"

            # repository
            repository = tna_document_row.repository
            return 'repository' if repository != "TNA"

            # department
            department = tna_document_row.department
            department_id = Ingest::DepartmentHelper.s_get_department_id_from_desc(department)
            return 'department' if department_id.blank?

            # series
            series = tna_document_row.series
            series_id = Ingest::SeriesHelper.s_get_series_id_from_desc(department_id, series)
            return 'series' if series_id.blank?

            # get document_json
            reference = tna_document_row.reference
            document_json = Ingest::DocumentHelper.s_get_document_json(series_id, reference)
            return 'document_json' if document_json.blank?

            document_id = document_json['id']

            # reference
            return "#{document_id}/reference" if (not reference.nil?) and reference != document_json['reference_tesim'][0]

            # publication
            publication = tna_document_row.publication
            return "#{document_id}/publication" if (not publication.nil?) and publication != document_json['publication_tesim'][0]

            # Summary
            summary = tna_document_row.summary
            return "#{document_id}/summary" if (not summary.nil?) and summary != document_json['summary_tesim'][0]

            # Entry date note
            entry_date_note = tna_document_row.entry_date_note
            return "#{document_id}/entry_date_note" if (not entry_date_note.nil?) and entry_date_note != document_json['entry_date_note_tesim'][0]

            # Note
            note = tna_document_row.note
            return "#{document_id}/note" if (not note.nil?) and note != document_json['note_tesim'][0]

            # Document type
            document_types_from_spreadsheet = [tna_document_row.document_type]
            unless document_types_from_spreadsheet.blank?
                document_types_from_spreadsheet = document_types_from_spreadsheet.map(&:capitalize)
                document_types_from_solr = Ingest::AuthorityHelper.s_get_entry_type_labels(document_json['document_type_tesim'])
                # compare document types and ignoring the order
                return "#{document_id}/document_type" if (document_types_from_spreadsheet & document_types_from_solr) != document_types_from_spreadsheet
            end

            # Date of document
            # date_of_document = tna_document_row.date_of_document
            # unless date_of_document.blank?
            #     return "#{document_id}/date of document" if date_of_document != document_json['first_date_full_ssim'][0]
            # end

            # Place of dating
            # place_of_dating = tna_document_row.place_of_dating
            # unless place_of_dating.blank?
            #     place_of_dating_descs = Ingest::ExcelHelper.extract_places_info(place_of_dating, 'place of dating', '')
            #     place_of_dating_descs.each do |place_of_dating_desc|
            #         place_of_dating_desc.country = 'England' if place_of_dating_desc.country.blank?
            #         return "#{document_id}/place_of_dating.place" unless document_json['place_same_as_facet_ssim'].include? "#{place_of_dating_desc.place_name}, #{place_of_dating_desc.county}, #{place_of_dating_desc.country}"
            #         return "#{document_id}/place_of_dating.place_as_written" unless document_json['place_as_written_tesim'].include? "#{place_of_dating_desc.place_as_written}"
            #     end
            # end

            # Place
            # place = tna_document_row.place
            # unless place.blank?
            #     place_descs = Ingest::ExcelHelper.extract_places_info(place, '', '')
            #     place_descs.each do |place_desc|
            #         place_desc.country = 'England' if place_desc.country.blank?
            #         return "#{document_id}/place.place" unless document_json['place_same_as_facet_ssim'].include? "#{place_desc.place_name}, #{place_desc.county}, #{place_desc.country}"
            #         return "#{document_id}/place.place_as_written" unless document_json['place_as_written_tesim'].include? "#{place_desc.place_as_written}"
            #     end
            # end

            # Language
            language = tna_document_row.language
            unless language.blank?
                return "#{document_id}/language" if language != document_json['language_facet_ssim'][0]
            end

            # Subject
            subjects_from_spreadsheet = [tna_document_row.subject]
            unless subjects_from_spreadsheet.blank?
                subjects_from_spreadsheet = subjects_from_spreadsheet.map(&:capitalize)
                subjects_from_solr = document_json['subject_facet_ssim']
                # compare subjects and ignoring the order
                return "#{document_id}/subject" if (subjects_from_spreadsheet & subjects_from_solr) != subjects_from_spreadsheet
            end

            # Addressee
            tna_document_row.addressee.split(";").each do |addressee|
                unless addressee.blank?
                    return "#{document_id}/addressee" unless document_json['tna_addressees_tesim'].include? addressee
                end
            end

            # Sender
            tna_document_row.sender.split(";").each do |sender|
                unless sender.blank?
                    return "#{document_id}/sender" unless document_json['tna_senders_tesim'].include? sender
                end
            end

            # Person
            tna_document_row.person.split(";").each do |person|
                unless person.blank?
                    return "#{document_id}/person" unless document_json['tna_persons_tesim'].include? person
                end
            end

            ""
        end

        # validate if all place authorities exist before ingest
        def self.validate_place(tna_document_row)
            log = Logger.new "log/tna_place_validator.log"
            documents_with_missing_place = []

            # check all place_of_dating fields to see if there are any place name haven't been indexed in the Place authority
            unless tna_document_row.place_of_dating.blank?
                place_of_dating_descs = Ingest::ExcelHelper.extract_places_info(tna_document_row.place_of_dating, 'place of dating', '')
                place_of_dating_descs.each_with_index do |place_of_dating_desc, index|
                    place_of_dating_id = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                        place_of_dating_desc.place_name,
                        place_of_dating_desc.county,
                        place_of_dating_desc.country)
                    documents_with_missing_place << "#{tna_document_row.reference} [#{index+1}]" if place_of_dating_id.blank?
                end
            end

            # check all place fields to see if there are any place name haven't been indexed in the Place authority
            unless tna_document_row.place.blank?
                place_descs = Ingest::ExcelHelper.extract_places_info(tna_document_row.place, '', '')
                place_descs.each_with_index do |place_desc, index|
                    place_id = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                        place_desc.place_name,
                        place_desc.county,
                        place_desc.country)
                    documents_with_missing_place << "#{tna_document_row.reference} (#{index+1})" if place_id.blank?
                end
            end
            documents_with_missing_place
        end

    end
end