namespace :cleanup do
  require 'csv'

  task reindex: :environment do

    q = SolrQuery.new
    q.solr_query('has_model_ssim:EntryDate', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      EntryDate.find(result['id']).update_index
    end
    q.solr_query('has_model_ssim:Entry', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      Entry.find(result['id']).update_index
    end
    q.solr_query('has_model_ssim:RelatedAgent', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      RelatedAgent.find(result['id']).update_index
    end
    q.solr_query('has_model_ssim:RelatedPlace', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      RelatedPlace.find(result['id']).update_index
    end

  end

  #could pass in the authority id and term to search
  task :places, [:name, :authority, :dryrun] => :environment do |t, args|

    # cawood
    # london
    # beverley
    # ebor

    puts 'looking for ' + args[:name]

    q = SolrQuery.new
    q.solr_query('has_model_ssim:RelatedPlace', 'id,place_as_written_tesim', 10000)['response']['docs'].each do |result|
      unless result['place_as_written_tesim'].nil?
        # find the authority, add to sameas
        if result['place_as_written_tesim'][0].downcase.starts_with? args[:name]
          if args[:dryrun].nil?
            r = RelatedPlace.find(result['id'])
            r.place_same_as = args[:authority]
            r.save
            auth = Place.find(args[:authority])
            if auth.used == nil
              auth.used = 'used'
              auth.save
            end
            puts 'added to ' + r.id
          else
            puts result['place_as_written_tesim'][0]
          end

        end
      end
    end

  end

  #could pass in the authority id and term to search
  task :people, [:name1,:name2,:authority,:dryrun] => :environment do |t, args|

    puts 'looking for ' + args[:name1] + ' ' + args[:name2]

    q = SolrQuery.new
    q.solr_query('has_model_ssim:RelatedAgent', 'id,person_as_written_tesim', 10000)['response']['docs'].each do |result|
      unless result['person_as_written_tesim'].nil?
        # find the authority, add to sameas
        if result['person_as_written_tesim'][0].downcase.include? args[:name1] and result['person_as_written_tesim'][0].downcase.include? args[:name2]
          if args[:dryrun].nil?
            r = RelatedAgent.find(result['id'])
            r.person_same_as = args[:authority]
            r.save
            auth = Person.find(args[:authority])
            if auth.used == nil
              auth.used = 'used'
              auth.save
            end
            puts 'added to ' + r.id
          else
            puts result['person_as_written_tesim'][0]
          end
        end
      end
    end

  end


  task same_as: :environment do

    q = SolrQuery.new
    q.solr_query('has_model_ssim:RelatedAgent', 'person_same_as_tesim', 10000)['response']['docs'].each do |result|
      unless result['person_same_as_tesim'].nil?
        begin
          person = Person.find(result['person_same_as_tesim'].join)
        rescue
          person = Group.find(result['person_same_as_tesim'].join)
        end
        if person.used.class == NilClass
          puts 'updating person ' + person.id
          person.used = 'used'
          person.save
        end
      end
    end

    q = SolrQuery.new
    q.solr_query('has_model_ssim:RelatedPlace', 'place_same_as_tesim', 10000)['response']['docs'].each do |result|
      unless result['place_same_as_tesim'].nil?

        place = Place.find(result['place_same_as_tesim'].join)

        if place.used.class == NilClass
          puts 'updating place ' + place.id
          place.used = 'used'
          place.save
        end
      end
    end
  end

  task subjects: :environment do

    q = SolrQuery.new
    q.solr_query('has_model_ssim:Entry', 'subject_tesim', 10000)['response']['docs'].each do |result|
      unless result['subject_tesim'].nil?

        result['subject_tesim'].each do |sub|
          subject = Concept.find(sub)

          if subject.used.class == NilClass
            puts 'updating subjects ' + subject.id
            subject.used = 'used'
            subject.save
          end
        end
      end
    end
  end

end

