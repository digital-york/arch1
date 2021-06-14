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

            # reference
            return 'reference' if (not reference.nil?) and reference != document_json['reference_tesim'][0]

            # publication
            publication = tna_document_row.publication
            return 'publication' if (not publication.nil?) and publication != document_json['publication_tesim'][0]

            # Summary
            summary = tna_document_row.summary
            return 'summary' if (not summary.nil?) and summary != document_json['summary_tesim'][0]

            # Entry date note
            entry_date_note = tna_document_row.entry_date_note
            return 'entry_date_note' if (not entry_date_note.nil?) and entry_date_note != document_json['entry_date_note_tesim'][0]

            # Note
            note = tna_document_row.note
            return 'note' if (not note.nil?) and note != document_json['note_tesim'][0]

            # Document type


            # Date of document


            # Place of dating


            # Place


            # Language


            # Subject


            # Addressee


            # Sender


            # Person


            # # Validate: compare entry_no from spreadsheet and entry_json from Solr
            # return 'entry_no' if entry_no != entry_json['entry_no_tesim'][0]
            #
            # # store entry_no into former_id as well
            # former_id = [borthwick_entry_row.entry_no.to_s]
            #
            # # entry types
            # entry_types = []
            # entry_types << borthwick_entry_row.entry_type1 unless borthwick_entry_row.entry_type1.blank?
            # entry_types << borthwick_entry_row.entry_type2 unless borthwick_entry_row.entry_type2.blank?
            # entry_types << borthwick_entry_row.entry_type3 unless borthwick_entry_row.entry_type3.blank?
            #
            # # Validate: compare entry_types from spreadsheet and from Solr
            # return 'entry_types' if entry_types.sort != Ingest::AuthorityHelper.s_get_entry_type_labels(entry_json['entry_type_tesim']).sort
            #
            # # language
            # # Q: NO language column in Reg7132v-entry-6-155-York-EHW.xlsx
            # languages = []
            # languages << borthwick_entry_row.language1 unless borthwick_entry_row.language1.blank?
            # languages << borthwick_entry_row.language2 unless borthwick_entry_row.language2.blank?
            #
            # # Validate: compare languages from spreadsheet and from Solr
            # unless languages.length == 0
            #     return 'languages' if languages.sort != Ingest::AuthorityHelper.s_get_language_labels(entry_json['language_tesim']).sort
            # end
            #
            # # Validate: compare section type from spreadsheet and from Solr
            # unless borthwick_entry_row.section_type.blank?
            #     return 'section type' if [borthwick_entry_row.section_type] != Ingest::AuthorityHelper.s_get_section_type_labels(entry_json['section_type_tesim'])
            # end
            #
            # # Validate: summary
            # return 'summary' if borthwick_entry_row.summary != entry_json['summary_tesim'][0]
            #
            # # subject
            # subjects = []
            # subjects << borthwick_entry_row.subject1 unless borthwick_entry_row.subject1.blank?
            # subjects << borthwick_entry_row.subject2 unless borthwick_entry_row.subject2.blank?
            # subjects << borthwick_entry_row.subject3 unless borthwick_entry_row.subject3.blank?
            # subjects << borthwick_entry_row.subject4 unless borthwick_entry_row.subject4.blank?
            #
            # # validate subjects
            # unless subjects.blank?
            #     return 'subject' if subjects.sort != Ingest::AuthorityHelper.s_get_subject_labels(entry_json['subject_tesim']).sort
            # end
            #
            # # validate note field
            # unless borthwick_entry_row.note.blank?
            #     return 'note' if entry_json['note_tesim'].blank? or (borthwick_entry_row.note != entry_json['note_tesim'][0])
            # end
            #
            # # validate is_referenced_by field
            # unless borthwick_entry_row.referenced_by.blank?
            #     return 'is_referenced_by' if borthwick_entry_row.referenced_by != entry_json['is_referenced_by_tesim'][0]
            # end
            #
            # # Validate entry dates
            # # 1) Find linked entry date1 and validate date role and note fields
            # entry_date1_id = ''
            # unless borthwick_entry_row.entry_date1_date_role.blank? and borthwick_entry_row.entry_date1_note.blank?
            #     #entry_date1_id = Ingest::EntryDateHelper.s_get_entry_date_id(entry_id, borthwick_entry_row.entry_date1_date_role, borthwick_entry_row.entry_date1_note)
            #     entry_date1_id = entry.entry_dates[0].id
            #     return 'entry_date1' if entry_date1_id.blank?
            # end
            #
            # # 2) Based on entry date1, find linked single date and validate date, certainty, and type fields
            # # There is NO reliable way to find the parent of a single date, e.g. the entry date by date note and date role - because lots of entry dates have the same role and note
            # # Therefore, cannot validate single_date
            # unless borthwick_entry_row.entry_date1_date.blank? and borthwick_entry_row.entry_date1_certainty.blank? and borthwick_entry_row.entry_date1_type.blank?
            #     single_date1_id = Ingest::EntryDateHelper.s_get_single_date_id(entry_date1_id,
            #                                                                    borthwick_entry_row.entry_date1_date,
            #                                                                    borthwick_entry_row.entry_date1_certainty,
            #                                                                    borthwick_entry_row.entry_date1_type
            #     )
            #     return "entry_date1_single_date1" if single_date1_id.blank?
            # end
            #
            # # 3) Find linked entry date2 and validate date role and note fields
            # unless borthwick_entry_row.entry_date2_date_role.blank? and borthwick_entry_row.entry_date2_note.blank?
            #     # entry_date2_id = Ingest::EntryDateHelper.s_get_entry_date_id(entry_id, borthwick_entry_row.entry_date2_date_role, borthwick_entry_row.entry_date2_note)
            #     entry_date2_id = entry.entry_dates[1].id
            #     return 'entry_date2' if entry_date2_id.blank?
            # end
            #
            # # 4) Based on entry date2, find linked single date and validate date, certainty, and type fields
            # unless borthwick_entry_row.entry_date2_date.blank? and
            #     borthwick_entry_row.entry_date2_certainty.blank? and
            #     borthwick_entry_row.entry_date2_type.blank?
            #     single_date2_id = Ingest::EntryDateHelper.s_get_single_date_id(entry_date2_id,
            #                                                                    borthwick_entry_row.entry_date2_date,
            #                                                                    borthwick_entry_row.entry_date2_certainty,
            #                                                                    borthwick_entry_row.entry_date2_type
            #     )
            #     return "entry_date2_single_date2" if single_date2_id.blank?
            # end
            #
            #
            # # related_places
            # related_places = []
            # unless borthwick_entry_row.place_as.blank? and
            #     borthwick_entry_row.place_name.blank? and
            #     borthwick_entry_row.place_role.blank? and
            #     borthwick_entry_row.place_type.blank? and
            #     borthwick_entry_row.place_note.blank?
            #     place_object_id = ''
            #     place_object_id = Ingest::AuthorityHelper.s_get_place_object_id(borthwick_entry_row.place_name) unless borthwick_entry_row.place_name.blank?
            #     place_role_ids = []
            #     place_role_ids = Ingest::AuthorityHelper.s_get_place_role_ids([borthwick_entry_row.place_role]) unless borthwick_entry_row.place_role.blank?
            #     place_type_ids = []
            #     place_type_ids = Ingest::AuthorityHelper.s_get_place_type_ids([borthwick_entry_row.place_type]) unless borthwick_entry_row.place_type.blank?
            #
            #     # Step 1: get related_place object, then check it against borthwick_entry_row.place_as
            #     unless borthwick_entry_row.place_as.blank?
            #         return "related_place.place_as_written" if Ingest::RelatedPlaceHelper.get_related_place_id(entry_id, borthwick_entry_row.place_as).blank?
            #     end
            #
            #     # Step 2: from place_object_id get Solr object, then compare the place_name_tesim with borthwick_entry_row.place_name
            #     unless borthwick_entry_row.place_name.blank?
            #         place_names = Ingest::AuthorityHelper.s_get_place_name(place_object_id)
            #         return "related_place.place_name" if place_names.blank? or (place_names.sort != [borthwick_entry_row.place_name].sort)
            #     end
            #
            #     # Step 3: from place_role_ids, get solr object, then compare the preflabel_tesim with borthwick_entry_row.place_role
            #     unless borthwick_entry_row.place_role.blank?
            #         return "related_place.place_role" if Ingest::AuthorityHelper.s_get_place_role_name(place_role_ids[0]).sort != [borthwick_entry_row.place_role].sort
            #     end
            #
            #     # Step 4: from place_type_ids, get solr object, then compare preflabel_tesim with borthwick_entry_row.place_type
            #     unless borthwick_entry_row.place_type.blank?
            #         return "related_place.place_type" if Ingest::AuthorityHelper.s_get_place_type_name(place_type_ids[0]) != [borthwick_entry_row.place_type]
            #     end
            #
            #     ""
            # end

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