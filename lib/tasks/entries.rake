namespace :entries do
  desc "TODO"
  task :process_entries, [:num] => :environment do | t,args |

    # This task processes the three spreadsheets of pilot data and creates all of the entries, dates, people and places
    # It's a bit of a monster, so will take a good while to run
    # You are advised to stop and start tomcat/solr before running it
    # If it fails then either run Entry.delete_all in the rails console - this may take a while but it does work
    # Or write a task to delete the existing objects
    # It shouldn't fail, though!
    require 'csv'

    @entry_mapping = Hash.new()
    @folio_mapping = Hash.new()

    puts args[:num]

    # Find the folio for each line
    puts 'Entries'
    CSV.foreach(Rails.root + "lib/assets/register12_data/#{args[:num]}/entries_subjects.csv") do |r|
      # strip whitespace, downcase
      r[0].gsub!(' ', '')
      r[0].gsub!('A', 'a')
      a = r[0].split('-')

      unless $. == 1 # skip header row
        #if $..modulo(50).zero?
          puts "processed #{$.} entries"
        #end
        fol = []
        #unless $. >= 7
          #we should see errors only where we don't have the folio (ie. blanks)

          # process the left hand value
          if a[0].end_with? 'v'
            q = 'preflabel_tesim:"Abp Reg 12 f.' + a[0][0, a[0].length-1] + ' (verso)*"'
            begin
              fol += [SolrQuery.new.solr_query(q, 'id')['response']['docs'].map.first['id']]
            rescue
              puts "#{a[0]}: #{$!}"
            end
          elsif a[0].end_with? 'r'
            q = 'preflabel_tesim:"Abp Reg 12 f.' + a[0][0, a[0].length-1] + ' (recto)*"'
            begin
              fol += [SolrQuery.new.solr_query(q, 'id')['response']['docs'].map.first['id']]
            rescue
              puts "#{a[0]}: #{$!}"
            end
          else
            puts 'I should never print'
          end

          if a[1] != a[0]
            # process the right hand value if it's different to the left
            if a[1].end_with? 'v'
              q = 'preflabel_tesim:"Abp Reg 12 f.' + a[1][0, a[1].length-1] + ' (verso)*"'
              begin
                fol += [SolrQuery.new.solr_query(q, 'id')['response']['docs'].map.first['id']]
              rescue
                puts "#{a[1]}: #{$!}"
              end
            elsif a[1].end_with? 'r'
              q = 'preflabel_tesim:"Abp Reg 12 f.' + a[1][0, a[1].length-1] + ' (recto)*"'
              begin
                fol += [SolrQuery.new.solr_query(q, 'id')['response']['docs'].map.first['id']]
              rescue
                puts "#{a[1]}: #{$!}"
              end
            else
              puts 'I should never print'
            end
          end

          # Now we have the folio ids build an entry object for each line
          unless fol == []
            ent = build_entry(r, fol)
            val = []

            #do a foreach with fol
            ent[:folio].each_with_index do |f, index|
              e = Entry.new
              e.rdftype = e.add_rdf_types
              ff = Folio.find(f)
              e.folio = ff
              e.former_id = [ent[:entry_no]]
              e.language = ent[:language]
              e.section_type = ent[:section_type]
              e.subject = ent[:subjects]
              #e.entry_type = entry_type_lookup
              #e.summary = ent[:summary].strip
              unless ent[:reference].nil?
                e.is_referenced_by = [ent[:reference]]
              end
              unless ent[:note].nil?
                e.note = ent[:note]
              end
              unless ent[:editorial_note].nil?
                e.editorial_note = [ent[:editorial_note]]
              end
              #continues
              if fol.length == 2 and index == 0
                e.continues_on = Folio.find(fol[1]).id #id not object
              end
              e.save
              ff.entries += [e]
              ff.save
              #puts "Adding Entry #{e.id}"
              # this should be entry pid
              #val[index] = e.former_id[0] + ':' + index.to_s
              val[index] = e.id
              if @folio_mapping[e.folio.id].nil?
                @folio_mapping[e.folio.id] = [e.id]
              else
                ents = @folio_mapping[e.folio.id]
                ents += [e.id]
                @folio_mapping[e.folio.id] = ents
              end
              @entry_mapping["#{r[4]}#{r[5]}"] = val
            end
          end
        #end
      end
    end

    # dates and places
    puts 'Dates and places'

    CSV.foreach(Rails.root + "lib/assets/register12_data/#{args[:num]}/dates_places.csv") do |d|
      unless $. == 1
        #if $..modulo(50).zero?
          puts "processed #{$.} dates and places"
        #end
        #unless $. >= 7
          entries = [] # the entries
          @entry_mapping["#{d[1]}#{d[2]}"].each do |e|
            entries += [e] # Entry.where(id: e).first
          end
          build_date_place(d, entries)
        #end
      end
    end

    # people and places
    puts 'People and places'
    CSV.foreach(Rails.root + "lib/assets/register12_data/#{args[:num]}/persons.csv") do |p|
      unless $. == 1
        #if $..modulo(50).zero?
          puts "processed #{$.} people and places"
        #end
        #unless $. >= 7
          entries = [] # the entries
          @entry_mapping["#{p[1]}#{p[2]}"].each do |e|
            entries += [e] # Entry.where(id: e).first
          end
          #pass the line and the list of entries for this person
          build_person(p, entries)
        #end
      end
    end

    # add entry numbers
    puts "Adding entry numbers"
    @folio_mapping.each do |f|
      f.each_with_index do |e, index|
        if index == 1
          e.each_with_index do |ee, index|
            ent = Entry.find(ee)
            num = index + 1
            ent.entry_no = num.to_s
            ent.save
          end
        end
      end
    end

  end

  def build_entry(line, fol)
    # lookup language
    unless line[3].nil?
      languages = line[3].to_s.split(';')
      lang_ids = []
      languages.each do |lang|
        response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"languages"', 'id')
        response['response']['docs'].map do |l|
          resp = SolrQuery.new.solr_query('inScheme_ssim:"' + l['id'] + '" AND preflabel_tesim:"' + lang.downcase + '"', 'id')
          resp['response']['docs'].map do |la|
            lang_ids += [la['id']]
          end
        end
      end
    end

    # lookup section type
    unless line[6].nil?
      section = line[6].to_s.split(';')
      sect_ids = []
      section.each do |sect|
        response = SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"section_types"', 'id')
        response['response']['docs'].map do |s|
          resp = SolrQuery.new.solr_query('inScheme_ssim:"' + s['id'] + '" AND preflabel_tesim:"' + sect.downcase + '"', 'id')
          resp['response']['docs'].map do |se|
            sect_ids += [se['id']]
          end
        end
      end
    end

    subs = []
    notes = []
    unless line[12].nil?
      term = subject_lookup(line[12])
      unless term.nil?
        subs << term
      end
      notes << "Subject: #{line[11]}, #{line[12]}, #{line[13]}"
    end
    unless line[15].nil?
      term = subject_lookup(line[15])
      unless term.nil?
        subs << term
      end
      notes << "Subject: #{line[14]}, #{line[15]}, #{line[16]}"
    end
    unless line[18].nil?
      term = subject_lookup(line[18])
      unless term.nil?
        subs << term
      end
      notes << "Subject: #{line[17]}, #{line[18]}, #{line[19]}"
    end
    unless line[21].nil?
      term = subject_lookup(line[21])
      unless term.nil?
        subs << term
      end
      notes << "Subject: #{line[20]}, #{line[21]}, #{line[22]}"
    end
    unless line[8].nil?
      notes << line[8].to_s
    end

    hash = {
        folio: fol,
        entry_no: 'Abp Reg 12 Entry ' + line[4] + line[5].to_s,
        language: lang_ids,
        section_type: sect_ids,
        subjects: subs,
        note: notes,
        #summary: line[7].to_s + ' ' + line[8].to_s,
    }

    unless line[7].nil?
      hash[:reference] = line[7].to_s
    end
    unless line[9].nil?
      hash[:editorial_note] = line[9].to_s
    end

    hash
  end

  def build_person(line, entries)

    entries.each do |e|
      # role is the one field that is ALWAYS present
      #unless line[9].nil?
        p = RelatedAgent.new

        naw = ''
        unless line[3].nil?
          naw += line[3] + ' '
        end
        unless line[4].nil?
          naw += line[4] + ' '
        end
        unless line[5].nil?
          naw += line[5] + ' '
        end
        unless line[6].nil?
          naw += line[6] + ' '
        end
        naw.gsub(' [ ]', '')
        naw.gsub('[ ]', '')
        naw.gsub(' []', '')
        naw.gsub('[]', '')
        naw.gsub('] [', ' ')
        naw.gsub('][', ' ')
        if naw == '?'
          naw = ''
        end
        if naw == ' '
          naw = ''
        end
        if naw.end_with?('  ')
          naw[0..naw.length-3]
        elsif naw.end_with? ' '
          naw = naw[0..naw.length-2]
        end

        # find out if this entry already has a person with the same name_as_written
        # if it does, add to that Person rather than create the new one
        pid = nil
        unless naw == ''
          begin
            pid = SolrQuery.new.solr_query('relatedAgentFor_ssim:"' + e + '" AND person_as_written_tesim:"' + naw + '"', 'id')['response']['docs'].map.first['id']
          rescue
            pid = nil
          end
        end
        unless pid.nil?
          puts 'add to existing (person): ' + pid
          # switch to the existing person
          p = RelatedAgent.find(pid)
        end

        # try and guess if it's a group
        if naw == ''
          begin
            if line[10].pluralize != line[10] && line[10].singularize == line[10]
              p.rdftype = p.add_rdf_types_p
            else
              p.rdftype = p.add_rdf_types_g
            end
          rescue
            p.rdftype = p.add_rdf_types_p
          end
        else
          p.person_as_written = [naw]
          p.rdftype = p.add_rdf_types_p
        end

        descriptors = []
        rel_places = []
        desc_as_written = []
        unless p.person_descriptor.nil?
          descriptors = p.person_descriptor
        end

        unless line[7].nil?
          descriptors += [person_descriptor_lookup(line[7].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
        end
        notes = []
        unless p.person_note.nil?
          notes = p.person_note
        end
        unless line[8].nil?
          desc_as_written += [line[8]]
        end

        # role and place

        unless line[9].nil?
          new_place_person(line[9], 'unknown', 'place of residence', p, nil, e)
        end

        roles = []
        unless p.person_role.nil?
          roles = p.person_role
        end
        unless line[10].nil?
          r, rn = person_role_lookup(line[10].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase)
          roles += [r]
          unless rn.nil?
            rolenote = ["Role: #{rn}"]
          end
        end

        unless line[11].nil?
          rel_places << line[11]
          if line[12].nil?
            new_place_person(line[11], 'unknown', 'place of person role', p, nil, e)
          else
            new_place_person(line[11], line[12].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'place of person role', p, nil, e)
          end
        end

        unless line[13].nil?
          descriptors += [line[13]]
        end

        unless line[14].nil?
          descriptors += [person_descriptor_lookup(line[14].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
        end
        unless line[15].nil?
          rel_places << line[15]
          stand = nil
          unless line[16].nil?
            stand = line[16]
          end
          if line[17].nil?
            new_place_person(line[15], 'unknown', 'place of person status', p, stand, e)
            desc_as_written += ["#{line[14]}, #{line[15]}"]
          else
            new_place_person(line[15], line[17].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'place of person status', p, stand, e)
            desc_as_written += ["#{line[14]}, #{line[15]}"]
          end

        end

        unless line[18].nil?
          descriptors += [person_descriptor_lookup(line[18].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
        end
        unless line[19].nil?
          rel_places << line[19]
          if line[20].nil?
            new_place_person(line[19], 'unknown', 'place of person status', p, nil, e)
            desc_as_written += ["#{line[18]}, #{line[19]}"]
          else
            new_place_person(line[19], line[20].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'place of person status', p, nil, e)
            desc_as_written += ["#{line[18]}, #{line[19]}"]
          end
        end

        unless line[21].nil?
          descriptors += [person_descriptor_lookup(line[21].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
        end
        unless line[22].nil?
          rel_places << line[22]
          if line[23].nil?
            new_place_person(line[22], 'unknown', 'place of person status', p, nil, e)
            desc_as_written += ["#{line[21]}"]
          else
            new_place_person(line[22], line[23].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'place of person status', p, nil, e)
            desc_as_written += ["#{line[21]}, #{line[22]}"]
          end
        end

        unless line[24].nil?
          descriptors += [person_descriptor_lookup(line[24].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
        end
        unless line[25].nil?
          rel_places << line[25]
          if line[26].nil?
            new_place_person(line[25], 'unknown', 'place of person status', p, nil, e)
            desc_as_written += ["#{line[24]}, #{line[25]}"]
          else
            new_place_person(line[25], line[26].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'place of person status', p, nil, e)
            desc_as_written += ["#{line[24]}, #{line[25]}"]
          end
        end

        unless line[27].nil?
          descriptors += [person_descriptor_lookup(line[27].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
        end
        unless line[28].nil?
          rel_places << line[28]
          if line[29].nil?
            new_place_person(line[28], 'unknown', 'place of person status', p, nil, e)
            desc_as_written += ["#{line[27]}, #{line[28]}"]
          else
            new_place_person(line[28], line[29].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'place of person status', p, nil, e)
            desc_as_written += ["#{line[27]}, #{line[28]}"]
          end
        end

        p.person_descriptor = descriptors
        p.person_related_place = rel_places
        p.person_descriptor_as_written = desc_as_written
        p.person_role += roles
        p.person_note = rolenote

        ee = Entry.find(e)
        p.entry = ee
        p.save
        ee.related_agents += [p]
        ee.save
        #puts "Adding Person #{p.id}"
      end
    #end
  end

  def build_date_place(line, entries)

    entries.each do |e|

      # (start, dend, inf, unc, app, role, note, entry)
      new_entry_date(line[3], line[4], line[5], line[6], line[7], line[8], line[11], e)

      unless line[12].nil?
        if line[17].nil?
          role = 'recited document date'
        else
          role = line[17]
        end
        new_entry_date(line[12], line[13], line[14], line[15], line[16], role, line[20], e)
      end

      unless line[21].nil?
        new_entry_date(line[21], nil, nil, nil, nil, 'recited document date', nil, e)
      end

      unless line[9].nil?
        new_place(line[9], line[10], 'document dated at', e)
      end

      unless line[18].nil?
        new_place(line[18], line[19], 'recited document date at', e)
      end

      unless line[22].nil?
        new_place(line[22], line[23], 'recited document date at', e)
      end
    end
  end

  def date_lookup(value)
    term = ''
    begin
      term = Terms::DateRoleTerms.new('subauthority').find_id_with_alts(value)
    rescue
    end
    if term == '' or term.nil?
      term = Terms::DateRoleTerms.new('subauthority').find_id_with_alts('unknown')
    end
    term
  end

  def place_type_lookup(value)
    term = ''
    begin
      term = Terms::PlaceTypeTerms.new('subauthority').find_id_with_alts(value)
    rescue
    end
    if term == '' or term.nil?
      term = Terms::PlaceTypeTerms.new('subauthority').find_id_with_alts('unknown')
    end
    term
  end

  def place_role_lookup(value)
    term = ''
    begin
      term = Terms::PlaceRoleTerms.new('subauthority').find_id_with_alts(value)
    rescue
    end
    if term == '' or term.nil?
      term = Terms::PlaceRoleTerms.new('subauthority').find_id_with_alts('recited date')
    end
    term
  end

  def person_role_lookup(value)
    term = ''
    term2 = nil
    begin
      term = Terms::PersonRoleTerms.new('subauthority').find_id_with_alts(value)
    rescue
    end
    if term == '' or term.nil?
      term = Terms::PersonRoleTerms.new('subauthority').find_id_with_alts('unknown')
      term2 = value
    end
    return term, term2
  end

  def person_descriptor_lookup(value)
    term = ''
    begin
      term = Terms::DescriptorTerms.new('subauthority').find_id_with_alts(value)
    rescue
    end
    if term == '' or term.nil?
      term = Terms::DescriptorTerms.new('subauthority').find_id_with_alts('unknown')
    end
    term
  end

  def subject_lookup(value)
    term = ''
    begin
      term = Terms::SubjectTerms.new('subauthority').find_id_with_alts(value)
    rescue
    end
    term
  end

  def new_entry_date(start, dend, inf, unc, app, role, note, entry)
    date = EntryDate.new
    date.rdftype = date.add_rdf_types
    ee = Entry.find(entry)
    date.entry = ee
    unless note.nil?
      date.date_note = note
    end

    unless role.nil?
      date.date_role = date_lookup(role.downcase)
    end
    date.save
    ee.entry_dates += [date]
    ee.save

    #puts "Adding EntryDate #{date.id}"

    s = SingleDate.new
    s.rdftype = s.add_rdf_types
    if start.include? '['
      start.gsub!('[', '')
    end
    if start.include? ']'
      start.gsub!(']', '')
    end
    if start.include? '-00'
      start.gsub!('-00', '')
    end

    if start == '0000'
      s.date = 'undated'
    else
      s.date = start.gsub('-','/')
    end

    certainty = []
    unless inf.nil? and unc.nil? and app.nil?
      if inf != "Yes"
        certainty += ['inferred']
      end
      if unc != "Yes"
        certainty += ['uncertain']
      end
      if app != "Yes"
        certainty += ['approximate']
      end
    end
    if certainty == []
      certainty = ['certain']
    end
    s.date_certainty = certainty

    # Is is a range?
    if dend.nil?
      s.date_type = 'single'
    else
      dend.gsub('[', '').gsub(']', '').gsub('-00', '').gsub('-','/')
      ss = SingleDate.new
      ss.rdftype = ss.add_rdf_types
      s.date_type = 'start'
      ss.date_type = 'end'
      unless certainty.nil?
        ss.date_certainty = certainty
      end
      s.date = dend
    end
    s.entry_date = date
    s.save
    date.single_dates += [s]
    date.save
    #puts "Adding SingleDate #{s.id}"
    unless ss.nil?
      ss.entry_date = date
      ss.save
      date.single_dates += [ss]
      date.save
      #puts "Adding SingleDate #{ss.id}"
    end
  end

  def new_place(written, ptype, role, entry)
    pl = RelatedPlace.new
    # find out if this entry already has a place with the same name_as_written
    # if it does, add to that Place rather than create the new one
    pid = nil
    unless written == ''
      begin
        pid = SolrQuery.new.solr_query('relatedPlaceFor_ssim:"' + entry + '" AND place_as_written_tesim:"' + written + '"', 'id')['response']['docs'].map.first['id']
      rescue
        pid = nil
      end
    end
    unless pid.nil?
      puts 'add to existing (place): ' + pid
      # switch to the existing place
      pl = RelatedPlace.find(pid)
    end

    pl.rdftype = pl.add_rdf_types
    pl.place_as_written = [written]
    pl.place_role = [place_role_lookup(role)]
    pl.place_type = [place_type_lookup(ptype)]
    ee = Entry.find(entry)
    pl.entry = ee
    pl.save
    ee.related_places += [pl]
    ee.save

  end

  def new_place_person(written, ptype, role, person, stand, entry)
    pl = RelatedPlace.new
    # find out if this entry already has a place with the same name_as_written
    # if it does, add to that Place rather than create the new one
    pid = nil
    unless written == ''
      begin
        pid = SolrQuery.new.solr_query('relatedPlaceFor_ssim:"' + entry + '" AND place_as_written_tesim:"' + written + '"', 'id')['response']['docs'].map.first['id']
      rescue
        pid = nil
      end
    end
    unless pid.nil?
      puts 'add to existing (place_person): ' + pid
      # switch to the existing place
      pl = RelatedPlace.find(pid)
    end
    pl.rdftype = pl.add_rdf_types
    pl.place_as_written = [written]
    pl.place_role = [place_role_lookup(role)]
    pl.place_type = [place_type_lookup(ptype)]
    pl.related_agent += [person]
    unless stand.nil?
      pl.place_note = [stand]
    end
    pl.save
    #why did I comment this out?
    #person.related_places += [pl]
    pl.related_agent += [person]
    if person.person_related_place.nil?
      person.person_related_place += [written]
    else
      person.person_related_place += [written]
    end
    person.save
    ee = Entry.find(entry)
    pl.entry = ee
    ee.related_places += [pl]
    ee.save
  end
end
