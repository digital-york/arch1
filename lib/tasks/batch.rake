require 'logger'

namespace :batch do

    # If Folio label is provided, will delete all entries within that Folio, e.g.
    #     bundle exec rake batch:delete_entries['Reg 9A']
    # If Folio label is not provided, will find all folios under the provided register
    #     then find entries and delete them under each folio, e.g.
    #     bundle exec rake batch:delete_entries['','Abp Reg 12 f.1 (recto)']
    desc "Batch delete entries within the provided Register/Folio."
    task :delete_entries, [:register_label, :folio_label] => [:environment] do |t, args|
        log = Logger.new "log/batch_delete_entries.log"
        register_label = args[:register_label]
        folio_label = args[:folio_label]

        print "  Are you sure to continue? type YES to confirm. "
        answer = STDIN.gets.chomp
        if answer == 'YES'
            if folio_label.blank?
                register_ids = Ingest::RegisterHelper.s_get_register_ids(register_label)
                register_ids.each_with_index do |register_id, index|
                    puts "For Register: #{register_id}"
                    folio_ids = Ingest::RegisterHelper.s_get_folio_ids(register_id)
                    folio_count = folio_ids.length
                    if folio_count > 0
                        folio_ids.each_with_index do |folio_id, index|
                            Batch::BatchHelper.delete_entries_in_folio(folio_id, '  ')
                        end
                    else
                        "No Folio found"
                    end
                end
            else
                folio_ids = Ingest::FolioHelper.s_get_folio_ids(folio_label)
                folio_ids.each do |folio_id|
                    Batch::BatchHelper.delete_entries_in_folio(folio_id)
                end
            end
        else
            puts 'Canceled.'
        end
    end

    # bundle exec rake batch:delete_entries_range['Abp Reg 12 f.1 (recto)','Abp Reg 12 f.12 (verso)']
    desc "Batch delete entries in range of folios"
    task :delete_entries_range, [:start_folio_label, :end_folio_label] => [:environment] do |t, args|
        log = Logger.new "log/batch_delete_entries_range.log"
        start_folio_label = args[:start_folio_label]
        end_folio_label = args[:end_folio_label]
        # print "  Are you sure to continue? type YES to confirm. "
        # answer = STDIN.gets.chomp
        # if answer == 'YES'
            finished = false
            current_folio_label = start_folio_label
            while not finished
                if current_folio_label == end_folio_label
                    finished = true  # exit when finished the current loop
                end
                puts "Processing #{current_folio_label}"
                folio_ids = Ingest::FolioHelper.s_get_folio_ids(current_folio_label)
                folio_ids.each do |folio_id|
                    Batch::BatchHelper.delete_entries_in_folio(folio_id)
                end
                current_folio_label = Ingest::FolioHelper.get_next_folio_label(current_folio_label)
            end
        # else
        #     puts 'Canceled.'
        # end
    end

    # If Series label is provided, will delete all documents within that Series, e.g.
    #     bundle exec rake batch:delete_documents['C']
    # If Series label is not provided, will find all series under the provided department
    #     then find documents and delete them under each series, e.g.
    #     bundle exec rake batch:delete_documents['C','C81']
    desc "Batch delete documents within the provided Department/Series."
    task :delete_documents, [:department_label, :series_label] => [:environment] do |t, args|
        log = Logger.new "log/batch_delete_documents.log"
        department_label = args[:department_label]
        series_label = args[:series_label]

        print "  Are you sure to continue? type YES to confirm. "
        answer = STDIN.gets.chomp
        if answer == 'YES'
            if series_label.blank?
                department_id = Ingest::DepartmentHelper.s_get_department_id(department_label)
                puts "For Department: #{department_id}"
                series_ids = Ingest::DepartmentHelper.s_get_series_ids(department_id)
                series_count = series_ids.length
                if series_count > 0
                    series_ids.each_with_index do |series_id, index|
                        Batch::BatchHelper.delete_documents_in_series(series_id, '  ')
                    end
                else
                    "No Series found"
                end
            else
                series_id = Ingest::SeriesHelper.s_get_series_id_from_label(series_label)
                Batch::BatchHelper.delete_documents_in_series(series_id)
            end
        else
            puts 'Canceled.'
        end
    end
end
