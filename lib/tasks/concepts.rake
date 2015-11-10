namespace :concepts do
  require 'csv'

  desc "TODO"
  task load_subjects: :environment do

    puts 'Creating the Concept Scheme'

    begin
      #@scheme = ConceptScheme.find('cj82k759n')

      @scheme = ConceptScheme.new
      @scheme.preflabel = "Borthwick Institute for Archives Subject Headings for the Archbishops' Registers"
      @scheme.description = "Borthwick Institute for Archives Subject Headings for the Archbishops' Registers. Produced from data created during the Archbishop's Registers Pilot project, funded by the Mellon Foundation."
      @scheme.rdftype = @scheme.add_rdf_types
      @scheme.save
      puts "Concept scheme for subjects created at #{@scheme.id}"
    rescue
      puts $!
    end

    puts 'Processing the subjects. This may take some time ... '


    arr = CSV.read(Rails.root + 'lib/assets/lists/subjects.csv')

    this_row = ''
    concept = nil

    arr.each do |c|
      begin
        # if the top concept hasn't been created, create it
        unless c[0] == this_row
          hh = Concept.new
          #create main heading
          hh.rdftype = hh.add_rdf_types
          #hh.id = hh.create_id(@scheme.id)
          hh.preflabel = c[0].strip
          hh.concept_scheme = @scheme
          hh.istopconcept = 'true'
          @scheme.concepts += [hh]
          @scheme.topconcept += [hh]
          @scheme.save
          hh.save
          puts "Top heading for #{hh.preflabel} created at #{hh.id}"
        end

        # create sub-heading
        h = Concept.new
        h.rdftype = h.add_rdf_types
        h.preflabel = c[1].strip
        #h.id = h.create_id(@scheme.id)
        h.concept_scheme = @scheme

        unless c[2].nil?
          if c[2].include? ';'
            a = c[2].gsub('; ', ';')
            b = a.split(';')
            h.altlabel = b
          else
            h.altlabel = [c[2]]
          end
        end
        unless c[3].nil?
          h.definition = c[3]
        end

        begin
          if hh
            h.broader += [hh]
          else
            hh = Concept.find(concept)
            h.broader += [hh]
          end

        rescue
          puts $!
        end
        h.save
        @scheme.concepts += [h]
        @scheme.save
        puts "Sub heading for #{h.preflabel} created at #{h.id} with broader #{hh.preflabel}"
        this_row = c[0]
        concept = hh.id
      rescue
        puts $!
      end
    end

    puts 'Finished!'
  end

  desc "TODO"
  task load_terms: :environment do

    path = Rails.root + 'lib/'
    # .csv files should exist in the specified path
    # removed as too short to be worth having a list for 'certainty', 'date_types'
    # removed as usued at present 'folio_faces', 'folio_types', 'formats'
    list = ['currencies', 'languages', 'place_types', 'descriptors', 'person_roles', 'place_roles', 'date_roles', 'section_types', 'entry_types']
    #list = ['currencies']
    list.each do |i|

      puts 'Creating the Concept Scheme'

      begin
        #@scheme = ConceptScheme.find('zc77sq08x')
        @scheme = ConceptScheme.new
        @scheme.preflabel = i
        @scheme.description = "Terms for #{i} produced from data created during the Archbishop's Registers Pilot project, funded by the Mellon Foundation."
        @scheme.rdftype = @scheme.add_rdf_types
        @scheme.save
        puts "Concept scheme for #{i} created at #{@scheme.id}"
      rescue
        puts $!
      end

      puts 'Processing ' + i + '. This may take some time ... '

      arr = CSV.read(path + "assets/lists/#{i}.csv")
      arr = arr.uniq # remove any duplicates

      arr.each do |c|
        begin
          h = Concept.new
          h.rdftype = h.add_rdf_types
          #h.id = h.create_id(@scheme.id)
          h.preflabel = c[0].strip
          h.concept_scheme = @scheme
          unless c[1].nil?
            if c[1].include? ';'
              a = c[1].gsub('; ', ';')
              b = a.split(';')
              h.altlabel += b
            else
              h.altlabel += [c[1]]
            end
          end
          h.save
          @scheme.concepts += [h]
          puts "Term for #{c[0]} created at #{h.id}"
        rescue
          puts $!
        end
      end
    end
    puts 'Finished!'
  end
end