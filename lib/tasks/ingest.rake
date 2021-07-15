require 'logger'
require 'json'

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
        log = Logger.new "log/excel.log"

        # Parse entry from Excel
        entry_rows   = Ingest::ExcelHelper.parse_borthwick_spreadsheet(args[:filename_xsl])
        allow_edit   = args[:allow_edit].to_s.downcase == 'true'
        entry_errors = []

        entry_rows.each_with_index { |entry_row, index|
            begin
                # For test purpose, only print selected entry rows
                # if index >= 1 and index < 4
                # if index < 1
                #if entry_row.folio_no == '610' and
                #   entry_row.folio_side == '(recto)' and
                #   entry_row.entry_no == '2'
                      puts "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                      log.info "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                      Ingest::BorthwickEntryBuilder.build_entry(entry_row, allow_edit)
                #end
                #elsif index >= 0  # the first line seems not a complete data (in Reg 9B 608)
                #    next
                #else
                #    break
                #end
            rescue => exception
                log.error exception.backtrace
                puts exception.backtrace
                entry_errors << "#{entry_row.register} / #{entry_row.folio_no} / #{entry_row.folio_side} / #{entry_row.entry_no}"
                puts "  Error"
            end
        }
        log.error "==========errors [#{entry_errors.length}]=========="
        log.error entry_errors
    end

    desc "Ingest TNA Departments from json file"
    # bundle exec rake ingest:tna_departments
    task tna_departments: :environment do
        json_file = File.read(Rails.root + 'lib/assets/departments/departments.json')
        json = JSON.parse(json_file)
        json.each do |k, v|
            Ingest::DepartmentHelper.create_department(k, v)
        end
    end

    desc "Ingest TNA Series from json file"
    # bundle exec rake ingest:tna_series
    task tna_series: :environment do
        json_file = File.read(Rails.root + 'lib/assets/series/series.json')
        json = JSON.parse(json_file)
        json.each do |k, v|
            department_id = Ingest::DepartmentHelper.s_get_department_id(k)
            if department_id.blank?
                puts '  Cannot find department ' + k
                next
            end
            v.each do |series_label, series_desc|
                puts "  #{series_label} => #{series_desc}"
                series = Ingest::SeriesHelper.create_series(series_label, series_desc, department_id)
                puts "    found/created: #{series.id}"
            end
        end
    end

    # The first parameter is the full path of Excel file
    # The second parameter allow_edit: allow edit of entries or not
    # e.g.
    # bundle exec rake ingest:tna_documents[/var/tmp/test.xlsx,false]
    # To disable warning messages:
    # RUBYOPT=-W0 bundle exec rake ingest:tna_documents[/home/frank/dlib/nw_data/tna_c81.xlsx,false]
    desc "Ingest tna documents from excel."
    task :tna_documents, [:filename_xsl,:allow_edit] => [:environment] do |t, args|
        log = Logger.new "log/tna_excel.log"

        # Parse documents from Excel
        document_rows   = Ingest::ExcelHelper.parse_tna_spreadsheet(args[:filename_xsl])
        allow_edit   = args[:allow_edit].to_s.downcase == 'true'
        document_errors = []

        document_rows.each_with_index { |document_row, index|
            begin
                # For test purpose, only print selected entry rows
                # if index >= 1 and index < 4
                # if index < 1
              # if document_row.reference == 'C 81/1786/44'
                puts "[#{index} / #{document_rows.length}] #{document_row.to_s}"
                log.info "[#{index} / #{document_rows.length}] #{document_row.to_s}"
                Ingest::TnaDocumentBuilder.build_document(document_row, allow_edit)
              # end
            rescue => exception
                log.error exception.backtrace
                puts exception.backtrace
                document_errors << "#{document_row.reference}"
                puts "  Error"
            end
        }
        log.error "==========errors [#{document_errors.length}]=========="
        log.error document_errors
    end
end
