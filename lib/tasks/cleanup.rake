namespace :cleanup do
  require 'csv'


  task broader: :environment do

    file = File.open("concepts.csv", "w")

    SolrQuery.new.solr_query('has_model_ssim:Concept and broader_tesim:*','id,broader_tesim',10000)['response']['docs'].each do |result|
      unless result['broader_tesim'].nil?
        file.write("#{result['id']},#{result['broader_tesim'].join}\n")
      end
    end
    file.close
  end

  task del_broader: :environment do

    CSV.read('concepts.csv').each_with_index do |broader,index|
      puts index
      c = Concept.find(broader[0])
      c.broader = nil
      c.save
      puts c
    end

  end


  #2514nk919,#<ActiveTriples::Resource:0x00000001aa2340>

  task add_broader: :environment do

    CSV.read('concepts.csv').each_with_index do |broader,index|
      puts index
      c = Concept.find(broader[0])
      if broader[1].include? 'Active'
        puts broader[0]
        puts broader[1]
      else
        cc = Concept.find(broader[1][broader[1].size-9..broader[1].size-1])
        c.broader << cc
        c.save
      end
    end

  end


    # Update all folios with the relationship to the register; this adds 'isPartOf_ssim' in solr
  task ispartof: :environment do
    #find all registers
    q = SolrQuery.new
    q.solr_query('has_model_ssim:Register', 'id', 50)['response']['docs'].each do |result|
      #get list of folios
      register = Register.find(result['id'])
      puts register.reg_id
      q.solr_query(result['id'] + '/list_source', 'ordered_targets_ssim', 50)['response']['docs'].map do |ot|
        fol1 = Folio.find(ot['ordered_targets_ssim'][0])
        fol2 = Folio.find(ot['ordered_targets_ssim'][ot['ordered_targets_ssim'].size - 1])
        if fol1.register.nil? or fol2.register.nil?
          ot['ordered_targets_ssim'].each_with_index do |target,index|
            puts index
            #update folio with isPartOf
            if q.solr_query('id:' + target, 'isPartOf_ssim', 1)['response']['docs'][0]['isPartOf_ssim'].nil?
              fol = Folio.find(target)
              fol.register = register
              fol.save
              puts fol.id + ' for reg ' + fol.register.reg_id
            end
          end
        end
      end
    end
  end

  task reindex1: :environment do

    Entry.find('s4655k12j').update_index

  end

  task reindex: :environment do

    q = SolrQuery.new
    q.solr_query('has_model_ssim:Entry', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      Entry.find(result['id']).update_index
    end
    q.solr_query('has_model_ssim:EntryDate', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      EntryDate.find(result['id']).update_index
    end
    q.solr_query('has_model_ssim:RelatedAgent', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      RelatedAgent.find(result['id']).update_index
    end
    q.solr_query('has_model_ssim:RelatedPlace', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      RelatedPlace.find(result['id']).update_index
    end
    q.solr_query('has_model_ssim:SingleDate', 'id', 10000)['response']['docs'].each do |result|
      puts result['id']
      SingleDate.find(result['id']).update_index
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

