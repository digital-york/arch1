require 'logger'

module Ingest
    # This class build an Entry from BorthwichEntryRow object
    class BorthwickEntryBuilder

        def self.build_entry(borthwick_entry_row, allow_edit=false)
            log = Logger.new "log/borthwick_entry_builder.log"

            # register_name
            register_name = borthwick_entry_row.register

            # Link entry to folio
            folio_id = Ingest::FolioHelper.s_get_ar_folio_id(borthwick_entry_row.register,
                                                             borthwick_entry_row.folio_no,
                                                             borthwick_entry_row.folio_side,
                                                             borthwick_entry_row.image_id)

            if folio_id.nil?
                puts 'cannot find folio: ' + borthwick_entry_row.folio_no + '/' + borthwick_entry_row.folio_side
                log.info 'cannot find folio via id: ' + borthwick_entry_row.folio_no + '/' + borthwick_entry_row.folio_side
                return nil
            end

            # entry number
            entry_no = borthwick_entry_row.entry_no.to_s
            # store entry_no into former_id as well
            former_id = [borthwick_entry_row.image_id.to_s] unless borthwick_entry_row.image_id.blank?
            # former_id = []

            # entry types
            entry_types = []
            entry_types << borthwick_entry_row.entry_type1 unless borthwick_entry_row.entry_type1.blank?
            entry_types << borthwick_entry_row.entry_type2 unless borthwick_entry_row.entry_type2.blank?
            entry_types << borthwick_entry_row.entry_type3 unless borthwick_entry_row.entry_type3.blank?

            # language
            # Q: NO language column in Reg7132v-entry-6-155-York-EHW.xlsx
            languages = []
            languages << borthwick_entry_row.language1 unless borthwick_entry_row.language1.blank?
            languages << borthwick_entry_row.language2 unless borthwick_entry_row.language2.blank?

            # section type
            section_type = Ingest::AuthorityHelper.s_get_section_type_object_ids([borthwick_entry_row.section_type])

            # subject
            subjects = []
            subjects << borthwick_entry_row.subject1 unless borthwick_entry_row.subject1.blank?
            subjects << borthwick_entry_row.subject2 unless borthwick_entry_row.subject2.blank?
            subjects << borthwick_entry_row.subject3 unless borthwick_entry_row.subject3.blank?
            subjects << borthwick_entry_row.subject4 unless borthwick_entry_row.subject4.blank?

            # is_referenced_by
            referenced_by = borthwick_entry_row.referenced_by unless borthwick_entry_row.referenced_by.blank?

            # Entry dates
            entry_dates = []
            entry_date1  = Ingest::EntryDateHelper.create_entry_date(borthwick_entry_row.entry_date1_date_role,
                                                                     borthwick_entry_row.entry_date1_note) unless borthwick_entry_row.entry_date1_date_role.blank? and borthwick_entry_row.entry_date1_note.blank?
            unless entry_date1.blank?
                entry_dates << entry_date1
                single_date1 = Ingest::EntryDateHelper.create_single_date(
                                       entry_date1,
                                       borthwick_entry_row.entry_date1_date,
                                       borthwick_entry_row.entry_date1_certainty,
                                       borthwick_entry_row.entry_date1_type) unless borthwick_entry_row.entry_date1_date.blank? and borthwick_entry_row.entry_date1_certainty.blank? and borthwick_entry_row.entry_date1_type.blank?
                entry_date1.single_dates << single_date1 unless single_date1.blank?
            end

            entry_date2  = Ingest::EntryDateHelper.create_entry_date(borthwick_entry_row.entry_date2_date_role,
                                                                     borthwick_entry_row.entry_date2_note) unless borthwick_entry_row.entry_date2_date_role.blank? and borthwick_entry_row.entry_date2_note.blank?

            unless entry_date2.blank?
                entry_dates << entry_date2
                single_date2 = Ingest::EntryDateHelper.create_single_date(
                        entry_date2,
                        borthwick_entry_row.entry_date2_date,
                        borthwick_entry_row.entry_date2_certainty,
                        borthwick_entry_row.entry_date2_type) unless borthwick_entry_row.entry_date2_date.blank? and borthwick_entry_row.entry_date2_certainty.blank? and borthwick_entry_row.entry_date2_type.blank?
                entry_date2.single_dates << single_date2 unless single_date2.blank?
            end

            # related_places
            related_places = []
            unless borthwick_entry_row.place_as.blank? and
                   borthwick_entry_row.place_name.blank? and
                   borthwick_entry_row.place_role.blank? and
                   borthwick_entry_row.place_type.blank? and
                   borthwick_entry_row.place_note.blank?
                place_object_id = ''
                place_object_id = Ingest::AuthorityHelper.s_get_place_object_id(borthwick_entry_row.place_name.to_s) unless borthwick_entry_row.place_name.blank?
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

            # editorial_note
            # no editorial_note field?

            e = Ingest::EntryHelper.create_or_update_entry(
                allow_edit,
                register_name,
                folio_id,
                entry_no,
                entry_types,
                former_id,
                languages,
                section_type,
                borthwick_entry_row.summary,
                borthwick_entry_row.marginalia,
                Ingest::AuthorityHelper.s_get_subject_object_ids(subjects),
                referenced_by,
                entry_dates,
                related_places,
                note,
                borthwick_entry_row.continues_folio_no,
                borthwick_entry_row.continues_folio_side,
                get_image_id(borthwick_entry_row.continues_image_id)
            )
        end

        # get the last image_id if multiple image ids are provided and seperated by ';'
        def self.get_image_id(image_ids)
            return image_ids if image_ids.blank?
            if image_ids.include? ";"
                image_ids.split(';').last
            else
                image_ids
            end
        end
    end
end