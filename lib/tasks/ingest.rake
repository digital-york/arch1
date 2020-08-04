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

    # bundle exec rake ingest:ingest_from_excel[EXCEL_FILE_NAME,ALLOW_EDIT]
    # The first parameter is the full path of Excel file
    # The second parameter allow_edit: allow edit of entries or not
    # e.g.
    # bundle exec rake ingest:ingest_from_excel[/var/tmp/test.xlsx,false]
    # To disable warning messages:
    # RUBYOPT=-W0 bundle exec rake ingest:excel[/var/tmp/test.xlsx,false]
    desc "Ingest entries from excel."
    task :excel, [:filename_xsl,:allow_edit] => [:environment] do |t, args|
        # Parse entry from Excel
        entry_rows   = Ingest::ExcelHelper.parse_borthwick_spreadsheet(args[:filename_xsl])
        allow_edit   = args[:allow_edit].to_s.downcase == 'true'
        entry_errors = []

        entry_rows.each_with_index { |entry_row, index|
            begin
                # For test purpose, only print selected entry rows
                # if index >= 1 and index < 4
                if index >= 1
                    #if index == 2
                      puts "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                      Ingest::BorthwickEntryBuilder.build_entry(entry_row, allow_edit)
                    #end
                elsif index >= 0  # the first line seems not a complete data (in Reg 9B 608)
                    next
                else
                    break
                end
            rescue => exception
                puts exception.backtrace
                entry_errors << "#{entry_row.register} / #{entry_row.folio_no} / #{entry_row.folio_side} / #{entry_row.entry_no}"
                puts "  Error"
            end
        }
        puts "==========errors=========="
        puts entry_errors
    end
end
