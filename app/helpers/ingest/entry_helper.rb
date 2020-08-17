require 'logger'

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

        # find Entry by Register No, Folio No, Folio side, and Entry No.
        # pry(main)> Ingest::EntryHelper.s_find_entry('zs25xb49m', '1')
        # => "2b88qc56f"
        def self.s_find_entry(folio_id, entry_no)
            entry_id = nil

            unless folio_id.nil?
                query = 'has_model_ssim:"Entry" AND folio_ssim:"'+folio_id+'" AND entry_no_tesim:"'+entry_no.to_s+'"'
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    entry_id = r['id']
                end
            end

            entry_id
        end

        # return Entry json from solr
        def self.s_get_entry_json(folio_id, entry_no)
            entry_json = nil
            unless folio_id.nil?
                query = 'has_model_ssim:"Entry" AND folio_ssim:"'+folio_id+'" AND entry_no_tesim:"'+entry_no.to_s+'"'
                fl = '*'
                SolrQuery.new.solr_query(query, fl)['response']['docs'].map do |r|
                    entry_json = r
                end
            end

            entry_json
        end

        # Ingest::EntryHelper.create_entry
        def self.create_or_update_entry(allow_edit,
                              register_name,
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
            log = Logger.new "log/entry_helper.log"

            entry_id = s_find_entry(folio_id, entry_no)

            if entry_id.nil?
                e = Entry.new
            else
                e = Entry.find(entry_id)
                puts '  found entry ' + entry_id
                log.info '  found entry ' + entry_id
                if allow_edit==false
                    return e
                end
            end

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

            # is_referenced_by (text field)
            e.is_referenced_by = [referenced_by] unless referenced_by.blank?

            # Entry dates
            e.entry_dates = entry_dates

            # place
            e.related_places = related_places

            # date
            # e.date = date

            # note (text field)
            e.note = [note] unless note.blank?

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
            puts "  Created/updated Entry: #{e.id}" unless e.nil?
            log.info "  Created/updated Entry: #{e.id}" unless e.nil?
            e
        end
    end
end