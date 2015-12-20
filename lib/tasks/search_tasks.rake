namespace :search_tasks do

  desc "TODO"

  task update_solr: :environment do

    Entry.all.each do |entry|
      puts entry.id
      entry.save
    end

  end

  end