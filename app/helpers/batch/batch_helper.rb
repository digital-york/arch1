require 'logger'

module Batch
    module BatchHelper
        def self.delete_entries_in_folio(folio_id, output_spaces='')
            return if folio_id.blank?

            puts "#{output_spaces}For Folio: #{folio_id}"
            entry_ids = Ingest::FolioHelper.s_get_all_entry_ids(folio_id)
            entry_count = entry_ids.length
            if entry_count > 0
                entry_ids.each_with_index do |entry_id, index|
                    print "#{output_spaces}  Deleting #{index+1}/#{entry_count} #{entry_id} ... "
                    #Entry.find(entry_id).delete
                    puts "Done."
                end
            else
                puts "#{output_spaces}  Donot find any entries."
            end
        end

        # Delete all documents within a series
        def self.delete_documents_in_series(series_id, output_spaces='')
            return if series_id.blank?

            puts "#{output_spaces}For Series: #{series_id}"
            document_ids = Ingest::SeriesHelper.s_get_all_document_ids(series_id)
            document_count = document_ids.length
            if document_count > 0
                document_ids.each_with_index do |document_id, index|
                    print "#{output_spaces}  Deleting #{index+1}/#{document_count} #{document_id} ... "
                    #Document.find(document_id).delete
                    puts "Done."
                end
            else
                puts "#{output_spaces}  Donot find any documents."
            end
        end
    end
end