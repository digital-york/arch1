namespace :ingest do

    # bundle exec rake ingest:ingest_from_excel[EXCEL_FILE_NAME]
    desc "Ingest entries from excel."
    task :ingest_from_excel, [:excel_file] => [:environment] do |t, args|
        # Parse entry from Excel
        entry_rows = Ingest::ExcelHelper.parse_borthwick_spreadsheet(args[:excel_file])
        entry_rows.each_with_index { |entry_row, index|
            # For test purpose, only print first 2 entry rows
            if index < 2
                puts entry_row.to_s
            else
                break
            end
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
            # Build notes field from subject, check entries.rake, from line 216

            # Create Entry object and save all attributes
            # entry.save
            # folio.entries += [entry]
            # folio.save
        }

    end

end