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
      @scheme = ConceptScheme.new
      @scheme.preflabel = "people"
      @scheme.rdftype = @scheme.add_rdf_types
      @scheme.save
      puts "Concept scheme for person created at #{@scheme.id}"
    rescue
      puts $!
    end

    puts 'Processing the person. This may take some time ... '

    arr = CSV.read(Rails.root + 'lib/assets/lists/persons.csv')

    arr.each do |c|
      begin

        p = Person.new
        p.rdftype = p.add_rdf_types
        p.concept_scheme = @scheme
        p.family = c[0].strip
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
              p.dates = d.gsub('0000-','d ')
            when d.end_with?('-0000')
              #remove and add b to beginning
              p.dates = 'b ' + d.gsub('-0000','')
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
              rel.gsub!('; ',';')
            end
            a = rel.split(';')
            p.related_authority += a
          else
            p.related_authority += [c[9]]
          end
        end
        unless c[10].nil?
          variant = c[10]
          if variant.include? ';'
            if variant.include? '; '
              variant.gsub!('; ',';')
            end
            variant.gsub('; ',';')
            a = variant.split(';')
            p.altlabel += a
          else
            p.altlabel += [c[10]]
          end
        end
        unless c[11].nil?
          p.note += [c[11]]
        end
        p.preflabel = "#{p.family}, #{p.pre_title}, #{p.given_name}, #{p.dates}, #{p.post_title}, #{p.epithet}".gsub('  ',' ').gsub(', ,',',').gsub(', ,',',').gsub(', ,',',')
        p.save
        puts "Created #{p.preflabel}"
      rescue
        puts $!
      end
    end
    puts 'Finished!'

  end

end
