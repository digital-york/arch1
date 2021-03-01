require 'date'
require 'logger'
require 'csv'

# Check missing fields in Solr
namespace :missing_field_checker do
    FIELDS_TO_CHECK = ["summary_tesim"].freeze
    log = Logger.new "log/field_checker.log"

    # bundle exec rake missing_field_checker:check
    desc "Check missing fields"
    task check: :environment do
        # rows=2147483647
        missing_entry_array = []
        SolrQuery.new.solr_query('-summary_tesim:["" TO *] AND has_model_ssim:Entry AND system_create_dtsi:[2017-01-01T00:00:00Z TO 2017-12-31T23:59:59Z]',
                                 fl='id,entry_no_tesim,folio_ssim,system_create_dtsi,system_modified_dtsi',
                                 rows=2147483647)['response']['docs'].map do |r|
            log.debug("This entry doesn't have summary field: " + r['id'])
            entry_label = r['entry_no_tesim'][0]
            folio_id = r['folio_ssim'][0]
            create_date = r['system_create_dtsi'][0..9]
            modify_date = r['system_modified_dtsi'][0..9]
            folio_label = Ingest::FolioHelper.get_folio_label(folio_id)
            register_label = folio_label.split(' f.')[0]
            folio_id = folio_label.split(' f.')[1]
            missing_entry = Report::MissingEntryReportDesc.new(
                register_label,
                folio_id,
                entry_label,
                create_date,
                modify_date
            )
            missing_entry_array << missing_entry
        end
        missing_entry_array.sort!
        CSV.open("log/missing_entry_report.csv", "w") do |csv|
            csv << ["Register","Folio","Entry","Creation Date","Modification Date"]
            missing_entry_array.each do |missing_entry|
                csv << [missing_entry.register_label,
                        missing_entry.folio_label,
                        missing_entry.entry_id,
                        missing_entry.create_date,
                        missing_entry.modify_date]
            end
        end

    end

end
