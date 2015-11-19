namespace :places_fortesting do
  desc "TODO"
  task pox: :environment do

    arr = CSV.read(Rails.root + 'lib/assets/yorkwest.csv')

    arr.each do | t |
      found = false
      auth = Deep.new('subauthority')

      q = t[0]
      if q.include? '-'
        q.gsub!('-',' ')
      end

      auth.search(q).each do | a |
        if a['featuretype'] == 'Parish' and (a['adminlevel2'].include? 'Nottingham') # or a['adminlevel2'].include? 'North')
          puts 'FOUND ' + a['label']
          found = true
        end
      end
      if not found
        puts t[0]
      end

      #adminlevel2
      #featuretype
    end

  end

end
