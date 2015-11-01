namespace :concepts do
  require 'csv'

  desc "TODO"
  task load_subjects: :environment do

    puts 'Creating the Concept Scheme'

    begin
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
        unless c[0] == this_row
          #create main heading
          hh = Concept.new
          hh.rdftype = hh.add_rdf_types
          hh.preflabel = c[0].strip
          hh.concept_scheme = @scheme
          hh.istopconcept = 'true'
          hh.save
          @scheme.topconcept += [hh]
          @scheme.save
          puts "Top heading for #{hh.preflabel} created at #{hh.id}"
        end

        # create sub-heading
        h = Concept.new
        h.rdftype = h.add_rdf_types
        h.preflabel = c[1].strip
        h.concept_scheme = @scheme
        unless c[2].nil?
          if c[2].include? ';'
            a = c[2].gsub('; ', ';')
            b = a.split(';')
            h.altlabel += b
          else
            h.altlabel += [c[2]]
          end
        end
        unless c[3].nil?
          h.definition = c[3]
        end
        if hh.nil?
          h.broader += [concept]
        else
          h.broader += [hh]
          concept = hh
        end
        h.save
        puts "Sub heading for #{h.preflabel} created at #{h.id}"

        this_row = c[0]
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
  # removed 'certainty', 'date_types'
  #list = ['folio_faces', 'folio_types', 'currencies', 'languages', 'place_types', 'descriptors', 'person_roles', 'place_roles', 'date_roles', 'formats', 'section_types', 'entry_types']
  list = ['descriptors']
  list.each do |i|

    puts 'Creating the Concept Scheme'

    begin
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
        #puts c[0]
        #puts c[1]
        h = Concept.new
        h.rdftype += h.add_rdf_types
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
      rescue
        puts $!
      end
    end
  end
  puts 'Finished!'
end
end
