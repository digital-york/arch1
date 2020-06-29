require 'roo'

namespace :ingest do

    # bundle exec rake ingest:ingest_from_excel[EXCEL_FILE_NAME]
    desc "Ingest entries from excel."
    task :ingest_from_excel, [:excel_file] => [:environment] do |t, args|
        entries = Roo::Spreadsheet.open(args[:excel_file])
        entries.each_with_index { |entry, index|
            if index < 2
                next
            end

            # Parse entry from Excel
            entry_row = Ingest::ExcelHelper.parse_borthwick_row(entry)



            # Create Entry object


            # For testing, exit after processed first 3 rows (0, 1 are the headers)
            if index > 2
                break
            end
        }

    end

end