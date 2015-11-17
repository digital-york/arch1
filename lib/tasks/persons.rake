namespace :persons do
  desc "TODO"
  task add_persons: :environment do

    # 0: Family Name
    # 1: Pre-Title
    # 2: Given Name
    # 3: Qualifyer
    # 4: Dates
    # 5: Dates of Office
    # 6: Title
    # 7: Epithet
    # 9: Related Authority
    # 10: Variant Names
    # 11: Notes

    puts 'Creating the Concept Scheme'

    begin
      @scheme = ConceptScheme.find('wp988j816')
      #@scheme = ConceptScheme.new
      #@scheme.preflabel = "people"
      #@scheme.rdftype = @scheme.add_rdf_types
      #@scheme.save
      puts "Concept scheme for person created at #{@scheme.id}"
    rescue
      puts "ERROR in ConceptScheme!"
      puts $!
      exit
    end

    puts 'Processing the person. This may take some time ... '

    AUTHS =
        {
         'Oxford Dictionary of Popes' => 'http://explore.bl.uk/primo_library/libweb/action/display.do?frbrVersion=3&tabs=moreTab&ct=display&fn=search&doc=BLL01009534313&indx=1&recIds=BLL01009534313&recIdxs=0&elementId=0&renderMode=poppedOut&displayMode=full&frbrVersion=3&dscnt=1&scp.scps=scope%3A%28BLCONTENT%29&frbg=&tab=local_tab&dstmp=1447001180115&srt=rank&mode=Basic&vl%28488279563UI0%29=any&dum=true&tb=t&vl%28freeText0%29=A%20Dictionary%20of%20Popes%201986&vid=BLVU1',
         'Heads of Religious Houses, III' => 'http://www.cambridge.org/gb/academic/subjects/history/british-history-1066-1450/heads-religious-houses-england-and-wales-iii-13771540?format=PB',
         'Fasti' => 'http://www.british-history.ac.uk/search/series/fasti-ecclesiae',
         'ODNB' => 'http://www.oxforddnb.com/',
         'http://www.etoncollege.com/Provosts.aspx' => 'http://www.etoncollege.com/Provosts.aspx',
         'Handbook of British Chronology' => 'http://www.cambridge.org/gb/academic/subjects/history/british-history-general-interest/handbook-british-chronology-3rd-edition'
         }

    #arr = CSV.read(Rails.root + 'lib/assets/lists/persons.csv')
    arr = CSV.read(Rails.root + 'lib/assets/lists/Persons_16_11_15.csv')

    arr.each do |c|
      begin

        p = Person.new
        p.rdftype << p.add_rdf_types
        #p.id = p.create_container_id(@scheme.id)
        p.concept_scheme = @scheme
        unless c[0].nil?
          p.family = c[0].strip
        end
        unless c[1].nil?
          p.pre_title = c[1].strip
        end
        unless c[2].nil?
          p.given_name = c[2].strip
        end
        unless c[3].nil?
          p.epithet = c[3].strip
        end
        unless c[4].nil?
          d = c[4].strip
          case
            when d == '0000-0000'
              #skip this one
            when d.start_with?('0000-')
              #replace with d
              p.dates = d.gsub('0000-', 'd ')
            when d.end_with?('-0000')
              #remove and add b to beginning
              p.dates = 'b ' + d.gsub('-0000', '')
            else
              p.dates = d
          end
        end
        unless c[5].nil?
          p.dates_of_office = c[5].strip
        end
        unless c[6].nil?
          p.post_title = c[6].strip
        end
        unless c[7].nil?
          if c[3].nil?
            p.epithet = c[7]
          else
            p.epithet += "; #{c[7]}"
          end
        end
        unless c[9].nil?
          rel = c[9]
          if rel.include? ';'
            if rel.include? '; '
              rel.gsub!('; ', ';')
            end
            a = rel.split(';')

            a.each do | aa |
              p.related_authority += [AUTHS[aa]]
            end

          else
            p.related_authority += [AUTHS[c[9]]]
          end
        end
        unless c[10].nil?
          variant = c[10]
          if variant.include? ';'
            if variant.include? '; '
              variant.gsub!('; ', ';')
            end
            variant.gsub('; ', ';')
            a = variant.split(';')
            p.altlabel += a
          else
            p.altlabel += [c[10]]
          end
        end
        unless c[11].nil?
          p.note += [c[11]]
        end
        p.preflabel = "#{p.family}, #{p.pre_title}, #{p.given_name}, #{p.dates}, #{p.post_title}, #{p.epithet}".gsub('  ', ' ').gsub(', ,', ',').gsub(', ,', ',').gsub(', ,', ',')
        if p.preflabel.start_with? ', '
          p.preflabel = p.preflabel[2..p.preflabel.length]
        end
        if p.preflabel.end_with? ', '
          p.preflabel = p.preflabel[0..p.preflabel.length-3]
        end
        p.save
        @scheme.persons += [p]
        @scheme.save
        puts "Created #{p.preflabel}"
      rescue
        puts "Error! #{p.preflabel}"
        puts $!
      end
    end
    puts 'Finished!'

  end

  task add_places: :environment do

    puts 'Creating the place Concept Scheme'

    begin

      @scheme = ConceptScheme.new
      @scheme.preflabel = "places"
      @scheme.rdftype = @scheme.add_rdf_types
      @scheme.save
      puts "Concept scheme for place created at #{@scheme.id}"
    rescue
      puts $!
    end
  end

end
