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
        entry_rows   = Ingest::ExcelHelper.parse_borthwick_spreadsheet(args[:filename_xsl])
        entry_errors = []
        entry_rows.each_with_index { |entry_row, index|
            begin
                # For test purpose, only print first 2 entry rows
                if index < 4
                    #if index == 2
                      puts entry_row.to_s
                      Ingest::BorthwickEntryBuilder.build_entry(entry_row)
                    #end
                else
                    break
                end
            rescue
                entry_errors << "#{entry_row.register} / #{entry_row.folio_no} / #{entry_row.folio_side} / #{entry_row.entry_no}"
                puts "  Error"
            end
        }
        puts "==========errors=========="
        puts entry_errors
    end
end
