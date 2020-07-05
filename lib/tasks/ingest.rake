namespace :ingest do

  desc "Ingest TNW Registers CSV spredsheet"
  # bundle exec rake ingest:borthwick_csv\[./lib/assets/tnw/Reg_7_132v-entry_6_155-York_EHW_ENTRIES.csv\]
  task :csv, [:filename_csv] => [:environment] do |t, args|
    # Parse entry from Excel
    entry_rows = Ingest::CsvHelper.parse_borthwick_spreadsheet(args[:filename_csv])
    entry_rows.each do |entry_row|
      puts entry_row.to_s
    end
  end

  # bundle exec rake ingest:ingest_from_excel[EXCEL_FILE_NAME]
  desc "Ingest entries from excel."
  task :excel, [:filename_xsl] => [:environment] do |t, args|
    # Parse entry from Excel
    entry_rows = Ingest::ExcelHelper.parse_borthwick_spreadsheet(args[:filename_xsl])
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
