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
                                                             borthwick_entry_row.folio_side)
            if folio_id.nil?
                puts 'cannot find folio: ' + borthwick_entry_row.to_s
                log.info 'cannot find folio: ' + borthwick_entry_row.to_s
                return nil
            end
            # entry number
            entry_no = borthwick_entry_row.entry_no.to_s

            # entry_id = Ingest::EntryHelper.s_find_entry(folio_id, borthwick_entry_row.entry_no)
            entry_json = Ingest::EntryHelper.s_get_entry_json(folio_id, entry_no)

            puts '  Entry ID: ' + entry_json['id']

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
            return 'entry_types' if entry_types != Ingest::AuthorityHelper.s_get_entry_type_labels(entry_json['entry_type_tesim'])

            # language
            # Q: NO language column in Reg7132v-entry-6-155-York-EHW.xlsx
            languages = []
            languages << borthwick_entry_row.language1 unless borthwick_entry_row.language1.blank?
            languages << borthwick_entry_row.language2 unless borthwick_entry_row.language2.blank?

            # Validate: compare languages from spreadsheet and from Solr
            unless languages.length == 0
                return 'languages' if languages != Ingest::AuthorityHelper.s_get_language_labels(entry_json['language_tesim'])
            end

            # Validate: compare section type from spreadsheet and from Solr
            return 'section type' if [borthwick_entry_row.section_type] != Ingest::AuthorityHelper.s_get_section_type_labels(entry_json['section_type_tesim'])

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
                return 'subject' if subjects != Ingest::AuthorityHelper.s_get_subject_labels(entry_json['subject_tesim'])
            end

            # validate note field
            return 'note' if borthwick_entry_row.note != entry_json['note_tesim'][0]




            # is_referenced_by
            referenced_by = borthwick_entry_row.referenced_by unless borthwick_entry_row.referenced_by.blank?

            # Entry dates
            entry_dates = []
            entry_date1  = Ingest::EntryDateHelper.create_entry_date(borthwick_entry_row.entry_date1_date_role,
                                                                     borthwick_entry_row.entry_date1_note) unless borthwick_entry_row.entry_date1_date_role.blank? and borthwick_entry_row.entry_date1_note.blank?
            unless entry_date1.blank?
                single_date1 = Ingest::EntryDateHelper.create_single_date(
                                       entry_date1,
                                       borthwick_entry_row.entry_date1_date,
                                       borthwick_entry_row.entry_date1_certainty,
                                       borthwick_entry_row.entry_date1_type) unless borthwick_entry_row.entry_date1_date.blank? and borthwick_entry_row.entry_date1_certainty.blank? and borthwick_entry_row.entry_date1_type.blank?
                entry_dates << entry_date1 unless entry_date1.blank?
            end


            entry_date2  = Ingest::EntryDateHelper.create_entry_date(borthwick_entry_row.entry_date2_date_role,
                                                                     borthwick_entry_row.entry_date2_note) unless borthwick_entry_row.entry_date2_date_role.blank? and borthwick_entry_row.entry_date2_note.blank?
            unless entry_date2.blank?
                single_date2 = Ingest::EntryDateHelper.create_single_date(
                        entry_date2,
                        borthwick_entry_row.entry_date2_date,
                        borthwick_entry_row.entry_date2_certainty,
                        borthwick_entry_row.entry_date2_type) unless borthwick_entry_row.entry_date2_date.blank? and borthwick_entry_row.entry_date2_certainty.blank? and borthwick_entry_row.entry_date2_type.blank?
                entry_dates << entry_date2 unless entry_date2.blank?
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
                related_place = Ingest::RelatedPlaceHelper.create_related_place(
                    borthwick_entry_row.place_as || '',
                    place_object_id,
                    place_role_ids,
                    place_type_ids,
                    [borthwick_entry_row.place_note || '']
                )
                related_places << related_place unless related_place.nil?
            end

            # leave group(1/2) for now

            # leave person(1/2/3) for now

            # note
            note = borthwick_entry_row.note unless borthwick_entry_row.note.blank?

            ''
        end

    end
end