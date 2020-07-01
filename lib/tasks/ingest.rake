require 'roo'

namespace :ingest do

    # bundle exec rake ingest:ingest_from_excel[EXCEL_FILE_NAME]
    desc "Ingest entries from excel."
    task :ingest_from_excel, [:excel_file] => [:environment] do |t, args|
        entries = Roo::Spreadsheet.open(args[:excel_file])
        entries.each_with_index { |entry, index|
            # Ignore the double header
            if index < 2
                next
            end

            # Parse entry from Excel
            entry_row = Ingest::ExcelHelper.parse_borthwick_row(entry)

            # Search Register from Solr
            #
            # If not found, log error
            #
            # Otherwise, get Register ID
            #

            # Search Folio from Solr, based on entry_row.folio_no and entry_row.folio_side
            # If not found, log error
            #
            # Else, get Folio id


            # Check entries.rake -> build_entry method,
            # Get attributes for an entry: language, section_type, note, reference, editorial_note


            # Create Entry object and save all attributes
            # entry.save
            # folio.entries += [entry]
            # folio.save


            # For testing, exit after processed first 3 rows (0, 1 are the headers)
            if index > 2
                break
            end
        }

    end

end