module Ingest
    # This class build an Entry from BorthwichEntryRow object
    class BorthwickEntryBuilder

        def self.build_entry(borthwick_entry_row)
            e = Entry.new

            # add entry rdf types
            e.rdftype = e.add_rdf_types

            # Link entry to folio
            folio_id = Ingest::FolioHelper.s_get_ar_folio_id(borthwick_entry_row.register,
                                                             borthwick_entry_row.folio_no,
                                                             borthwick_entry_row.folio_side)
            if folio_id.nil?
                return nil
            end
            e.folio = Folio.find(folio_id)

            # entry number
            e.entry_no = borthwick_entry_row.entry_no.to_s
            # store entry_no into former_id as well
            e.former_id = [borthwick_entry_row.entry_no.to_s]

            # language
            # Q: NO language column in Reg7132v-entry-6-155-York-EHW.xlsx

            # section type
            e.section_type = Ingest::AuthorityHelper.s_get_section_type_object_ids([borthwick_entry_row.section_type])

            # subject
            subjects = []
            subjects << borthwick_entry_row.subject1 unless borthwick_entry_row.subject1.blank?
            subjects << borthwick_entry_row.subject2 unless borthwick_entry_row.subject2.blank?
            subjects << borthwick_entry_row.subject3 unless borthwick_entry_row.subject3.blank?
            subjects << borthwick_entry_row.subject4 unless borthwick_entry_row.subject4.blank?
            e.subject = subjects

            # is_referenced_by
            e.is_referenced_by = [borthwick_entry_row.referenced_by] unless borthwick_entry_row.referenced_by.blank?

            # note
            e.note = [borthwick_entry_row.note] unless borthwick_entry_row.note.blank?

            # editorial_note
            # no editorial_note field?

            # Continued folio no and side
            unless borthwick_entry_row.continues_folio_no.blank? or borthwick_entry_row.continues_folio_side.blank?
                continuted_folio_id = Ingest::FolioHelper.s_get_ar_folio_id(
                                                        borthwick_entry_row.register,
                                                        borthwick_entry_row.folio_no,
                                                        borthwick_entry_row.folio_side)
                continuted_folio = Folio.find(continuted_folio_id)
                e.continues_on = continuted_folio unless continuted_folio.nil?
            end

            e.save
            e.folio.entries += [e]
            e.folio.save

            e
        end

    end
end