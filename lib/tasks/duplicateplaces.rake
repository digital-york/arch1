require 'logger'
require 'tnw_common/report/duplicate_places'

namespace :duplicateplaces do

    # bundle exec rake duplicateplaces:excel[EXCEL_FILE_NAME]
    # The parameter is the full path of Excel file
    # e.g.
    # bundle exec rake duplicateplaces:excel[/var/tmp/test2.xlsx]
    # To disable warning messages:
    # RUBYOPT=-W0 bundle exec rake duplicateplaces:excel[/var/tmp/test2.xlsx]
    desc "Check duplicate places used in the spreadsheets."
    task :excel, [:filename_xsl] => [:environment] do |t, args|
        log = Logger.new "log/duplicate_places.log"

        duplicate_places =TnwCommon::Report::DuplicatePlaces.new(SOLR[Rails.env]['url']).report()

        # Parse entry from Excel
        entry_rows   = Ingest::ExcelHelper.parse_borthwick_spreadsheet(args[:filename_xsl])
        duplicate_places_entries = []
        errors = []

        entry_rows.each_with_index { |entry_row, index|
            begin
                if duplicate_places.keys.include? entry_row.place_name
                    puts '  duplicate: ' + entry_row.to_s + ': ' + entry_row.place_name
                    log.info '  duplicate: ' + entry_row.to_s + ': ' + entry_row.place_name
                    duplicate_places_entries << entry_row.to_s
                end
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
        if duplicate_places_entries.length > 0
            log.error "==========mismatches [#{duplicate_places_entries.length}]=========="
            # log.error duplicate_places_entries
        end
    end
end
