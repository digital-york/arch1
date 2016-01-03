namespace :persons do
  desc "TODO"
  task add_persons: :environment do

    # 0: Family Name
    # 1: Pre-Title
    # 2: Given Name
    # 3: Qualifier
    # 4: Dates
    # 5: Dates of Office
    # 6: Title
    # 7: Epithet
    # 9: Related Authority
    # 10: Variant Names
    # 11: Notes

    puts 'Creating the Concept Scheme'

    begin

      response = SolrQuery.new.solr_query(q='preflabel_tesim:"people" AND has_model_ssim:"ConceptScheme"', fl='id', rows=1)['response']

      if response['numFound'] == 0
        @scheme = ConceptScheme.new
        @scheme.preflabel = "people"
        @scheme.rdftype = @scheme.add_rdf_types
        @scheme.save
        puts "Concept scheme for person created at #{@scheme.id}"
      else
        @scheme = ConceptScheme.find(response['docs'][0]['id'])
        puts "Using existing Concept scheme #{@scheme.id}"
      end

    rescue
      puts "ERROR in ConceptScheme!"
      puts $!
      exit
    end

    puts 'Processing the person. This may take some time ... '

    arr = CSV.read(Rails.root + 'lib/assets/lists/persons.csv')

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
          p.related_authority = []
          rel = c[9]
          if rel.include? ';'
            if rel.include? '; '
              rel.gsub!('; ', ';')
            end
            a = rel.split(';')

            a.each do | aa |
              p.related_authority << aa
            end

          else
            p.related_authority << c[9]
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

        begin
          p.save
        rescue
          puts "Error! #{p.preflabel}"
          puts ">> #{$!}"
        end

        @scheme.persons += [p]
        @scheme.save
        puts "Created #{p.preflabel}"
      rescue
        puts $!
      end
    end
    puts 'Finished!'

  end

  task add_groups: :environment do

    puts 'Creating the place Concept Scheme'

    begin

      #@scheme = ConceptScheme.find('hq37vn837')
      @scheme = ConceptScheme.new
      @scheme.preflabel = "groups"
      @scheme.rdftype = @scheme.add_rdf_types
      @scheme.save
      puts "Concept scheme for groups created at #{@scheme.id}"
    rescue
      puts $!
    end

    puts 'Processing the religious houses. This may take some time ... '

    arr = CSV.read(Rails.root + 'lib/assets/lists/houses.csv')

    arr.each do |c|
      begin

        p = Group.new
        p.rdftype << p.add_rdf_types
        p.concept_scheme = @scheme
        p.name = c[0].strip
        unless c[2].nil?
          p.name += ' ' + c[2].strip
        end
        p.name += ' ' + c[3].strip
        p.group_type = [c[3].strip]

        unless c[6].nil?
          p.qualifier = c[6].strip
        end
        p.related_authority = []

        unless c[7].nil?
          p.related_authority += [c[7]]
        end
        unless c[1].nil?
          p.altlabel += [c[1]]
        end
        notes = 'County: ' + c[5]
        if c[4] == 'F'
          notes += '; Gender: Female'
        elsif c[4] == 'M'
          notes += '; Gender: Male'
        end
        p.note = [notes]
        p.preflabel = "#{p.name}, #{p.qualifier}"
        p.save

        @scheme.groups += [p]
        @scheme.save
        puts "Created #{p.preflabel}"
      rescue
        puts $!
      end
    end
    puts 'Finished!'

  end

  # this updates people IN OPAL from a spreadsheet; ids in the spreadsheet are from opal
  # this has not yet been tested
  task update_persons: :environment do

    # 0: id
    # 1: Family Name
    # 2: Given Name
    # 3: Dates
    # 4: Pre-Title
    # 5: epithet
    # 6: Dates of Office
    # 7: Related Authority
    # 8: Variant Names

    # ??: Title - I missed this from the source sheet so it won't be updated

    begin

      response = SolrQuery.new.solr_query(q='preflabel_tesim:"people" AND has_model_ssim:"ConceptScheme"', fl='id', rows=1)['response']
      @scheme = ConceptScheme.find(response['docs'][0]['id'])
      puts "Using existing Concept scheme #{@scheme.id}"

    rescue
      puts "ERROR in ConceptScheme!"
      puts $!
      exit
    end

    puts 'Processing the person. This may take some time ... '

    arr = CSV.read(Rails.root + 'lib/assets/lists/persons_full.csv')

    arr.each do |c|
      begin
        # 0: id
        #p = Person.find(c[0])
        p = Person.new()
        p.rdftype << p.add_rdf_types
        p.concept_scheme = @scheme
        # 1: Family Name
        unless c[1].nil? or c[1] == ''
          p.family = c[1].strip
        end
        # 2: Given Name
        unless c[2].nil? or c[2] == ''
          p.given_name = c[2].strip
        end
        # 3: Dates
        unless c[3].nil? or c[3] == ''
          p.dates = c[3].strip
        end
        # 4: Pre-Title
        unless c[4].nil? or c[4] == ''
          p.pre_title = c[4].strip
        end
        # 5: epithet
        unless c[5].nil? or c[5] == ''
          p.epithet = c[5].strip.gsub('\,',',')
        end
        # 6: Dates of Office
        unless c[6].nil? or c[6] == ''
          p.dates_of_office = c[6].strip
        end
        # 7: Related Authority
        unless c[7].nil? or c[7] == ''
          p.related_authority = [c[7].strip.gsub('\,',',')]
        end
        # 8: Variant Names
        unless c[8].nil? or c[8] == ''
          if c[8].include? ','
            c[8].split(',').each do | v |
              p.altlabel << v.strip
            end
          else
          p.altlabel = [c[8].strip]
          end

        end
        p.preflabel = "#{p.family}, #{p.pre_title}, #{p.given_name}, #{p.dates}, #{p.post_title}, #{p.epithet}".gsub('  ', ' ').gsub(', ,', ',').gsub(', ,', ',').gsub(', ,', ',')
        if p.preflabel.start_with? ', '
          p.preflabel = p.preflabel[2..p.preflabel.length]
        end
        if p.preflabel.end_with? ', '
          p.preflabel = p.preflabel[0..p.preflabel.length-3]
        end

        begin
          p.save
        rescue
          puts "Error! #{p.preflabel}"
          puts ">> #{$!}"
        end

        @scheme.persons += [p]
        @scheme.save
        puts "Updated #{p.preflabel}"
      rescue
        puts $!
      end
    end
    puts 'Finished!'

  end

end
