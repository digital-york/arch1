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
                # if entry_row.folio_no == '7' and
                #   entry_row.folio_side == '(verso)' and
                #   entry_row.entry_no == '1'
                      # puts "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                      # log.info "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                      first_mismatched_field = Validator::BorthwickEntryValidator.validate_entry(entry_row)
                      unless first_mismatched_field.blank?
                          puts "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                          log.info "[#{index} / #{entry_rows.length}] #{entry_row.to_s}"
                          puts '  mismatch: ' + first_mismatched_field
                          log.info '  mismatch: ' + first_mismatched_field
                          mismatched_entries << entry_row.to_s + " => #{first_mismatched_field}"
                      end
                    # break
                # end
            rescue => exception
                log.error exception.backtrace
                puts exception.backtrace
                errors << "#{entry_row.register} / #{entry_row.folio_no} / #{entry_row.folio_side} / #{entry_row.entry_no}"
            end
        }
        if errors.length > 0
            log.error "==========errors [#{errors.length}]=========="
            log.error errors
        end
        if mismatched_entries.length > 0
            log.error "==========mismatches [#{mismatched_entries.length}]=========="
            log.error mismatched_entries
        end
    end

    # bundle exec rake validate:tna_place[EXCEL_FILE_NAME]
    # The parameter is the full path of Excel file
    # e.g.
    # bundle exec rake validate:tna_place[/home/frank/dlib/nw_data/tna_c81.xlsx]
    # To disable warning messages:
    # RUBYOPT=-W0 bundle exec rake validate:tna_place[/home/frank/dlib/nw_data/tna_c81.xlsx]
    desc "Validate TNA places from excel against solr and report missing ones."
    task :tna_place, [:filename_xsl] => [:environment] do |t, args|
        log = Logger.new "log/validate_tna_places.log"

        # Parse TNA documents from Excel
        document_rows   = Ingest::ExcelHelper.parse_tna_spreadsheet(args[:filename_xsl])
        document_with_missing_places = []
        errors = []

        document_rows.each_with_index { |document_row, index|
            begin
                missing_places = Validator::TnaValidator.validate_place(document_row)
                unless missing_places.blank?
                    missing_places.each do |missing_place|
                        document_with_missing_places << missing_place
                    end
                end
            rescue => exception
                log.error exception.backtrace
                puts exception.backtrace
                errors << "#{document_row}"
            end
        }
        if errors.length > 0
            log.error "==========errors [#{errors.length}]=========="
            log.error errors
        end
        if document_with_missing_places.length > 0
            log.info "==========document with missing places [#{document_with_missing_places.length}]=========="
            puts document_with_missing_places
        end
    end
end
