require 'logger'

namespace :validate do

    # bundle exec rake validate:excel[EXCEL_FILE_NAME]
    # The parameter is the full path of Excel file
    # e.g.
    # bundle exec rake validate:excel[/var/tmp/test2.xlsx]
    # To disable warning messages:
    # RUBYOPT=-W0 bundle exec rake validate:excel[/var/tmp/test2.xlsx]
    desc "Validate entries from excel against solr."
    task :excel, [:filename_xsl] => [:environment] do |t, args|
        log = Logger.new "log/validate.log"

        # Parse entry from Excel
        entry_rows   = Ingest::ExcelHelper.parse_borthwick_spreadsheet(args[:filename_xsl])
        mismatched_entries = []
        errors = []

        entry_rows.each_with_index { |entry_row, index|
            begin
                # For test purpose, only print selected entry rows
                if entry_row.folio_no == '613' and
                   entry_row.folio_side == '(recto)' and
                   entry_row.entry_no == '1'
                      puts "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                      log.info "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                      first_mismatched_field = Validator::BorthwickEntryValidator.validate_entry(entry_row)
                      if first_mismatched_field.nil?
                          print '  ERROR'
                      elsif first_mismatched_field == ''
                          print '  match'
                      else
                          print '  mismatch: ' + first_mismatched_field
                          mismatched_entries << entry_row.to_s + " => #{first_mismatched_field}"
                      end
                    break
                end
            rescue => exception
                log.error exception.backtrace
                puts exception.backtrace
                errors << "#{entry_row.register} / #{entry_row.folio_no} / #{entry_row.folio_side} / #{entry_row.entry_no}"
                puts "  Error"
            end
        }
        if errors.length > 0
            log.error "==========errors [#{errors.length}]=========="
            log.error errors
        end
        if mismatched_entries.length > 0
            log.error "==========errors [#{mismatched_entries.length}]=========="
            log.error mismatched_entries
        end
    end
end
