module Ingest
    module EntryHelper
        # search folio's id by the given label
        # make sure to check the returned array
        # normally it should only return 1 element
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_folio_ids(folio_label)
            ids = nil
            SolrQuery.new.solr_query("preflabel_tesim:\"#{folio_label}\"")['response']['docs'].map do |r|
                ids = r['id']
            end
        end

        # Ingest::FolioHelper.create_entry
        def self.create_entry(register_name,
                              folio_id,
                              entry_no,
                              entry_types,
                              former_id,
                              languages,
                              section_type,
                              summary,
                              subjects,
                              referenced_by,
                              entry_dates,
                              related_places,
                              note,
                              continues_folio_no,
                              continues_folio_side
                              )
            # CHANGE ME HERE
            # #################
            # # #################
            # # #################
            #e = Entry.new
            e = Entry.find('2b88qc56f')
            # #################
            # # #################

            # add entry rdf types
            e.rdftype = e.add_rdf_types

            # link entry to folio
            e.folio = Folio.find(folio_id)

            # entry number
            e.entry_no = entry_no

            # store former_id/entry_no into former_id
            e.former_id = former_id

            e.entry_type = Ingest::AuthorityHelper.s_get_entry_type_object_ids(entry_types)

            # language
            # Q: NO language column in Reg7132v-entry-6-155-York-EHW.xlsx
            e.language = Ingest::AuthorityHelper.s_get_language_object_ids(languages) unless languages.blank?

            # section type
            e.section_type = section_type

            # summary
            e.summary = summary

            # subject
            e.subject = subjects unless subjects.blank?

            # is_referenced_by
            # Find the authority object by the referenced_by text
            #e.is_referenced_by = [referenced_by] unless referenced_by.blank?

            # Entry dates
            e.entry_dates = entry_dates

            # place
            e.related_places = related_places

            # date
            # e.date = date

            # note
            # e.note = [note] unless note.blank?

            # editorial_note
            # no editorial_note field?

            # Continued folio no and side
            unless continues_folio_no.blank? or continues_folio_side.blank?
                continuted_folio_id = Ingest::FolioHelper.s_get_ar_folio_id(
                                            register_name,
                                            continues_folio_no,
                                            continues_folio_side)
                continuted_folio = Folio.find(continuted_folio_id)
                e.continues_on = continuted_folio unless continuted_folio.nil?
            end

            e.save
#            e.folio.entries += [e]
#            e.folio.save

            e
        end
    end
end