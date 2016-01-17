namespace :cleanup do
  require 'csv'

  desc "TODO"
  task registers: :environment do

    Register.all.each do |r|

      if r.preflabel == 'Abp Reg 32: Richard Neile (1632-1640):  John Williams (1641-1650)'
        r.preflabel = 'Abp Reg 32: Samuel Harsnett (1619-1631), Richard Neile (1632-1640), John Williams (1641-1650)'
        r.save
      end
    end
  end

  task neville: :environment do


  end

  #could pass in the authority id and term to search
  task :places, [:name, :authority] => :environment  do | t,args |

    # cawood
    # london
    # beverley
    # york

    puts 'looking for ' + args[:name]

    q = SolrQuery.new
    q.solr_query('has_model_ssim:RelatedPlace', 'id,place_as_written_tesim', 10000)['response']['docs'].each do |result|
      unless result['place_as_written_tesim'].nil?
        # find the authority, add to sameas
        if result['place_as_written_tesim'][0].downcase.starts_with? args[:name]
          r = RelatedPlace.find(result['id'])
          r.place_same_as = args[:authority]
          r.save
          puts 'added to ' + r.id
        end
      end
    end

  end

  #could pass in the authority id and term to search
  task :people, [:name1,:name2, :authority] => :environment  do | t,args |

    # cawood
    # london
    # beverley
    # york

    puts 'looking for ' + args[:name1] + ' ' args[:name2]

    q = SolrQuery.new
    q.solr_query('has_model_ssim:RelatedPlace', 'id,person_as_written_tesim', 10000)['response']['docs'].each do |result|
      unless result['person_as_written_tesim'].nil?
        # find the authority, add to sameas
        if result['person_as_written_tesim'][0].downcase.include? args[:name1] and result['person_as_written_tesim'][0].downcase.include? args[:name2]
            r = RelatedAgent.find(result['id'])
          r.place_same_as = args[:authority]
          r.save
          puts 'added to ' + r.id
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

end

