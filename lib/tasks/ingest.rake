require 'smarter_csv'
require 'roo'

namespace :ingest do

    # To run this task, type:
    # bundle exec rake ingest:ingest_from_csv[/var/tmp/x.csv]
    desc "Ingest entries from CSV."
    task :ingest_from_csv, [:csvfile] => [:environment] do |t, args|
        # map columns in row 1 to its parent in row 0
        parent_mappings = {}

        # No changes to column 0-7
        [*1..7].each do |i|
            parent_mappings[i] = i
        end
        parent_mappings[8] = 8 # Folio No. -> Continues/End
        parent_mappings[9] = 8 # Folio side -> Continues/End


        Ingest::CsvHelper.merge_double_header(args[:csvfile], '/var/tmp/x2.csv', parent_mappings)
        #entries = SmarterCSV.process(args[:csvfile])
        #puts entries
    end

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