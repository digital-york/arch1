require 'logger'

module Validator
    # This class build an Entry from BorthwichEntryRow object
    class BorthwickEntryValidator

        # if mismatch found, return first mismatched field name as string
        # else return empty string
        def self.validate_entry(borthwick_entry_row)
            log = Logger.new "log/borthwick_entry_validator.log"

            # register_name
            register_name = borthwick_entry_row.register

            # Link entry to folio
            folio_id = Ingest::FolioHelper.s_get_ar_folio_id(borthwick_entry_row.register,
                                                             borthwick_entry_row.folio_no,
                                                             borthwick_entry_row.folio_side,
                                                             borthwick_entry_row.image_id)
            if folio_id.nil?
                puts 'cannot find folio: ' + borthwick_entry_row.to_s
                log.info 'cannot find folio: ' + borthwick_entry_row.to_s
                return nil
            end
            # entry number
            entry_no = borthwick_entry_row.entry_no.to_s

            # entry_id = Ingest::EntryHelper.s_find_entry(folio_id, borthwick_entry_row.entry_no)
            entry_json = Ingest::EntryHelper.s_get_entry_json(folio_id, entry_no)
            entry_id = entry_json['id']
            entry = Entry.find(entry_id)
            # puts '  Entry ID: ' + entry_id

            # Validate: compare entry_no from spreadsheet and entry_json from Solr
            return 'entry_no' if entry_no != entry_json['entry_no_tesim'][0]

            # store entry_no into former_id as well
            former_id = [borthwick_entry_row.entry_no.to_s]

            # entry types
            entry_types = []
            entry_types << borthwick_entry_row.entry_type1 unless borthwick_entry_row.entry_type1.blank?
            entry_types << borthwick_entry_row.entry_type2 unless borthwick_entry_row.entry_type2.blank?
            entry_types << borthwick_entry_row.entry_type3 unless borthwick_entry_row.entry_type3.blank?

            # Validate: compare entry_types from spreadsheet and from Solr
            return 'entry_types' if entry_types.sort != Ingest::AuthorityHelper.s_get_entry_type_labels(entry_json['entry_type_tesim']).sort

            # language
            # Q: NO language column in Reg7132v-entry-6-155-York-EHW.xlsx
            languages = []
            languages << borthwick_entry_row.language1 unless borthwick_entry_row.language1.blank?
            languages << borthwick_entry_row.language2 unless borthwick_entry_row.language2.blank?

            # Validate: compare languages from spreadsheet and from Solr
            unless languages.length == 0
                return 'languages' if languages.sort != Ingest::AuthorityHelper.s_get_language_labels(entry_json['language_tesim']).sort
            end

            # Validate: compare section type from spreadsheet and from Solr
            unless borthwick_entry_row.section_type.blank?
                return 'section type' if [borthwick_entry_row.section_type] != Ingest::AuthorityHelper.s_get_section_type_labels(entry_json['section_type_tesim'])
            end

            # Validate: summary
            return 'summary' if borthwick_entry_row.summary != entry_json['summary_tesim'][0]

            # subject
            subjects = []
            subjects << borthwick_entry_row.subject1 unless borthwick_entry_row.subject1.blank?
            subjects << borthwick_entry_row.subject2 unless borthwick_entry_row.subject2.blank?
            subjects << borthwick_entry_row.subject3 unless borthwick_entry_row.subject3.blank?
            subjects << borthwick_entry_row.subject4 unless borthwick_entry_row.subject4.blank?

            # validate subjects
            unless subjects.length == 0
                return 'subject' if subjects.sort != Ingest::AuthorityHelper.s_get_subject_labels(entry_json['subject_tesim']).sort
            end

            # validate note field
            unless borthwick_entry_row.note.blank?
                return 'note' if entry_json['note_tesim'].blank? or (borthwick_entry_row.note != entry_json['note_tesim'][0])
            end

            # validate is_referenced_by field
            unless borthwick_entry_row.referenced_by.blank?
                return 'is_referenced_by' if borthwick_entry_row.referenced_by != entry_json['is_referenced_by_tesim'][0]
            end

            # Validate entry dates
            # 1) Find linked entry date1 and validate date role and note fields
            entry_date1_id = ''
            unless borthwick_entry_row.entry_date1_date_role.blank? and borthwick_entry_row.entry_date1_note.blank?
                #entry_date1_id = Ingest::EntryDateHelper.s_get_entry_date_id(entry_id, borthwick_entry_row.entry_date1_date_role, borthwick_entry_row.entry_date1_note)
                entry_date1_id = entry.entry_dates[0].id
                return 'entry_date1' if entry_date1_id.blank?
            end

            # 2) Based on entry date1, find linked single date and validate date, certainty, and type fields
            # There is NO reliable way to find the parent of a single date, e.g. the entry date by date note and date role - because lots of entry dates have the same role and note
            # Therefore, cannot validate single_date
            unless borthwick_entry_row.entry_date1_date.blank? and borthwick_entry_row.entry_date1_certainty.blank? and borthwick_entry_row.entry_date1_type.blank?
                single_date1_id = Ingest::EntryDateHelper.s_get_single_date_id(entry_date1_id,
                                                                               borthwick_entry_row.entry_date1_date,
                                                                               borthwick_entry_row.entry_date1_certainty,
                                                                               borthwick_entry_row.entry_date1_type
                                                                               )
                return "entry_date1_single_date1" if single_date1_id.blank?
            end

            # 3) Find linked entry date2 and validate date role and note fields
            unless borthwick_entry_row.entry_date2_date_role.blank? and borthwick_entry_row.entry_date2_note.blank?
                # entry_date2_id = Ingest::EntryDateHelper.s_get_entry_date_id(entry_id, borthwick_entry_row.entry_date2_date_role, borthwick_entry_row.entry_date2_note)
                entry_date2_id = entry.entry_dates[1].id
                return 'entry_date2' if entry_date2_id.blank?
            end

            # 4) Based on entry date2, find linked single date and validate date, certainty, and type fields
            unless borthwick_entry_row.entry_date2_date.blank? and
                   borthwick_entry_row.entry_date2_certainty.blank? and
                   borthwick_entry_row.entry_date2_type.blank?
                single_date2_id = Ingest::EntryDateHelper.s_get_single_date_id(entry_date2_id,
                                                                               borthwick_entry_row.entry_date2_date,
                                                                               borthwick_entry_row.entry_date2_certainty,
                                                                               borthwick_entry_row.entry_date2_type
                )
                return "entry_date2_single_date2" if single_date2_id.blank?
            end


            # related_places
            related_places = []
            unless borthwick_entry_row.place_as.blank? and
                   borthwick_entry_row.place_name.blank? and
                   borthwick_entry_row.place_role.blank? and
                   borthwick_entry_row.place_type.blank? and
                   borthwick_entry_row.place_note.blank?
                place_object_id = ''
                place_object_id = Ingest::AuthorityHelper.s_get_place_object_id(borthwick_entry_row.place_name) unless borthwick_entry_row.place_name.blank?
                place_role_ids = []
                place_role_ids = Ingest::AuthorityHelper.s_get_place_role_ids([borthwick_entry_row.place_role]) unless borthwick_entry_row.place_role.blank?
                place_type_ids = []
                place_type_ids = Ingest::AuthorityHelper.s_get_place_type_ids([borthwick_entry_row.place_type]) unless borthwick_entry_row.place_type.blank?

                # Step 1: get related_place object, then check it against borthwick_entry_row.place_as
                unless borthwick_entry_row.place_as.blank?
                    return "related_place.place_as_written" if Ingest::RelatedPlaceHelper.get_related_place_id(entry_id, borthwick_entry_row.place_as).blank?
                end

                # Step 2: from place_object_id get Solr object, then compare the place_name_tesim with borthwick_entry_row.place_name
                unless borthwick_entry_row.place_name.blank?
                    place_names = Ingest::AuthorityHelper.s_get_place_name(place_object_id)
                    return "related_place.place_name" if place_names.blank? or (place_names.sort != [borthwick_entry_row.place_name].sort)
                end

                # Step 3: from place_role_ids, get solr object, then compare the preflabel_tesim with borthwick_entry_row.place_role
                unless borthwick_entry_row.place_role.blank?
                    return "related_place.place_role" if Ingest::AuthorityHelper.s_get_place_role_name(place_role_ids[0]).sort != [borthwick_entry_row.place_role].sort
                end

                # Step 4: from place_type_ids, get solr object, then compare preflabel_tesim with borthwick_entry_row.place_type
                unless borthwick_entry_row.place_type.blank?
                    return "related_place.place_type" if Ingest::AuthorityHelper.s_get_place_type_name(place_type_ids[0]) != [borthwick_entry_row.place_type]
                end

                ""
            end

        end

    end
end