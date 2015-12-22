namespace :entries do
  desc "TODO"
  task process_entries: :environment do

    # This task processes the three spreadsheets of pilot data and creates all of the entries, dates, people and places
    # It's a bit of a monster, so will take a good while to run
    # You are advised to stop and start tomcat/solr before running it
    # If it fails run Entry.delete_all in the rails console - this may take a while but it does work

    require 'csv'

    @entry_mapping = Hash.new()
    @folio_mapping = Hash.new()

    # find the register id and the folio_faces ids
    register = SolrQuery.new.solr_query('reg_id_tesim:"Abp Reg 12"', 'id')['response']['docs'].map.first['id']
    recto, verso = '', ''
    SolrQuery.new.solr_query('has_model_ssim:"ConceptScheme" AND preflabel_tesim:"folio_faces"', 'id')['response']['docs'].map do |face|
      q = "inScheme_ssim:\"#{face['id']}\" AND preflabel_tesim:"
      recto = SolrQuery.new.solr_query(q + 'recto', 'id')['response']['docs'].map.first['id']
      verso = SolrQuery.new.solr_query(q + 'verso', 'id')['response']['docs'].map.first['id']
    end

    # Find the folio for each line
    puts 'Entries'
    CSV.foreach(Rails.root + 'lib/assets/register12_data/entries_subjects.csv') do |r|
      # strip whitespace, downcase
      r[0].gsub!(' ', '')
      r[0].gsub!('A', 'a')
      a = r[0].split('-')

      unless $. == 1 # skip header row
        if $..modulo(50).zero?
          puts "processed #{$.} entries"
        end
        fol = []
        #unless $. >= 7
        #we should see errors only where we don't have the folio (ie. blanks)

        # process the left hand value
        if a[0].end_with? 'v'
          q = "isPartOf_ssim:\"#{register}\" AND folio_no_tesim:\"#{a[0][0, a[0].length-1]}\" AND folio_face_tesim:\"#{verso}\""
          begin
            fol += [SolrQuery.new.solr_query(q, 'id,folio_no_tesim,folio_face_tesim')['response']['docs'].map.first['id']]
          rescue
            puts "#{a[0]}: #{$!}"
          end
        elsif a[0].end_with? 'r'
          q = "isPartOf_ssim:\"#{register}\" AND folio_no_tesim:\"#{a[0][0, a[0].length-1]}\" AND folio_face_tesim:\"#{recto}\""
          begin
            fol += [SolrQuery.new.solr_query(q, 'id,folio_no_tesim,folio_face_tesim')['response']['docs'].map.first['id']]
          rescue
            puts "#{a[0]}: #{$!}"
          end
        else
          puts 'I should never print'
        end

        if a[1] != a[0]
          # process the right hand value if it's different to the left
          if a[1].end_with? 'v'
            q = "isPartOf_ssim:\"#{register}\" AND folio_no_tesim:\"#{a[1][0, a[1].length-1]}\" AND folio_face_tesim:\"#{verso}\""
            begin
              fol += [SolrQuery.new.solr_query(q, 'id,folio_no_tesim,folio_face_tesim')['response']['docs'].map.first['id']]
            rescue
              puts "#{a[1]}: #{$!}"
            end
          elsif a[1].end_with? 'r'
            q = "isPartOf_ssim:\"#{register}\" AND folio_no_tesim:\"#{a[1][0, a[1].length-1]}\" AND folio_face_tesim:\"#{recto}\""
            begin
              fol += [SolrQuery.new.solr_query(q, 'id,folio_no_tesim,folio_face_tesim')['response']['docs'].map.first['id']]
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
            ff = Folio.where(id: f).first
            e.folio = ff
            e.former_id = [ent[:entry_no]]
            e.language = ent[:language]
            e.section_type = ent[:section_type]
            e.entry_type = entry_type_lookup
            e.summary = ent[:summary].strip
            unless ent[:reference].nil?
              e.is_referenced_by = [ent[:reference]]
            end
            unless ent[:note].nil?
              e.note = [ent[:note]]
            end
            unless ent[:editorial_note].nil?
              e.editorial_note = [ent[:editorial_note]]
            end
            #continues
            if fol.length == 2 and index == 0
              e.continues_on = Folio.where(id: fol[1]).first.id #id not object
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
    CSV.foreach(Rails.root + 'lib/assets/register12_data/dates_places.csv') do |d|
      unless $. == 1
        if $..modulo(50).zero?
          puts "processed #{$.} dates and places"
        end
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
    CSV.foreach(Rails.root + 'lib/assets/register12_data/persons.csv') do |p|
      unless $. == 1
        if $..modulo(50).zero?
          puts "processed #{$.} people and places"
        end
        #unless $. >= 30
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
            ent = Entry.where(id: ee).first
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


    hash = {
        folio: fol,
        entry_no: 'Abp Reg 12 Entry ' + line[4] + line[5].to_s,
        language: lang_ids,
        section_type: sect_ids,
        summary: line[7].to_s + ' ' + line[8].to_s,
    }

    unless line[9].nil?
      hash[:reference] = line[9].to_s
    end
    unless line[11].nil?
      hash[:note] = line[11].to_s
    end
    unless line[12].nil?
      hash[:editorial_note] = line[12].to_s
    end
    hash
  end

  def build_person(line, entries)

    entries.each do |e|

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
      naw.gsub('] [', ' ')
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
        p = RelatedAgent.where(id: pid).first
      end

      # try and guess if it's a group
      if naw == ''
        begin
          if line[9].pluralize != line[9] && line[9].singularize == line[9]
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
        notes += [line[8]]
      end

      # role and place

      roles = []
      unless p.person_role.nil?
        roles = p.person_role
      end
      unless line[9].nil?
        roles += [person_role_lookup(line[9].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase)]
      end

      unless line[10].nil?
        if line[11].nil?
          new_place_person(line[10], 'unknown', 'person role (for now)', p, nil, e)
          notes += ["#{line[9]}, #{line[10]}"]
        else
          new_place_person(line[10], line[11].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'person role (for now)', p, nil, e)
          notes += ["#{line[9]}, #{line[10]}, #{line[11]}"]
        end
      end

      unless line[13].nil?
        descriptors += [line[13]]
      end

      unless line[14].nil?
        descriptors += [person_descriptor_lookup(line[14].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
      end
      unless line[15].nil?
        stand = nil
        unless line[16].nil?
          stand = line[16]
        end
        if line[17].nil?
          new_place_person(line[15], 'unknown', 'person status (for now)', p, stand, e)
          notes += ["#{line[14]}, #{line[15]}"]
        else
          new_place_person(line[15], line[17].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'person status (for now)', p, stand, e)
          notes += ["#{line[14]}, #{line[15]}, #{line[17]}"]
        end

      end

      unless line[19].nil?
        descriptors += [person_descriptor_lookup(line[19].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
      end
      unless line[20].nil?
        if line[21].nil?
          new_place_person(line[20], 'unknown', 'person status (for now)', p, nil, e)
          notes += ["#{line[19]}, #{line[20]}"]
        else
          new_place_person(line[20], line[21].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'person status (for now)', p, nil, e)
          notes += ["#{line[19]}, #{line[20]}, #{line[21]}"]
        end
      end

      unless line[23].nil?
        descriptors += [person_descriptor_lookup(line[23].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
      end
      unless line[24].nil?
        if line[25].nil?
          new_place_person(line[24], 'unknown', 'person status (for now)', p, nil, e)
          notes += ["#{line[23]}, #{line[24]}"]
        else
          new_place_person(line[24], line[25].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'person status (for now)', p, nil, e)
          notes += ["#{line[23]}, #{line[24]}, #{line[25]}"]
        end
      end

      unless line[27].nil?
        descriptors += [person_descriptor_lookup(line[27].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
      end
      unless line[28].nil?
        if line[28].nil?
          new_place_person(line[28], 'unknown', 'person status (for now)', p, nil, e)
          notes += ["#{line[27]}, #{line[28]}"]
        else
          new_place_person(line[28], line[29].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'person status (for now)', p, nil, e)
          notes += ["#{line[27]}, #{line[28]}, #{line[29]}"]
        end
      end

      unless line[31].nil?
        descriptors += [person_descriptor_lookup(line[31].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
      end
      unless line[32].nil?
        if line[29].nil?
          new_place_person(line[32], 'unknown', 'person status (for now)', p, nil, e)
          notes += ["#{line[31]}, #{line[32]}"]
        else
          new_place_person(line[32], line[33].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'person status (for now)', p, nil, e)
          notes += ["#{line[31]}, #{line[32]}, #{line[33]}"]
        end
      end

      unless line[35].nil?
        descriptors += [person_descriptor_lookup(line[35].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize)]
      end
      unless line[36].nil?
        if line[37].nil?
          new_place_person(line[36], 'unknown', 'person status (for now)', p, nil, e)
          notes += ["#{line[35]}, #{line[36]}"]
        else
          new_place_person(line[36], line[37].gsub('[', '').gsub(']', '').gsub('?', '').strip.downcase.singularize, 'person status (for now)', p, nil, e)
          notes += ["#{line[35]}, #{line[36]}, #{line[37]}"]
        end
      end

      p.person_descriptor = descriptors
      p.person_descriptor_as_written = notes
      p.person_role += roles
      ee = Entry.where(id: e).first
      p.entry = ee
      p.save
      ee.related_agents += [p]
      ee.save
      #puts "Adding Person #{p.id}"
    end
  end

  def build_date_place(line, entries)

    entries.each do |e|

      # (start, dend, inf, unc, app, role, note, entry)
      new_entry_date(line[3], line[4], line[5], line[6], line[7], line[8], line[12], e)

      unless line[13].nil?
        new_entry_date(line[13], line[14], line[15], line[16], line[17], line[18], line[21], e)
      end

      unless line[22].nil?
        new_entry_date(line[13], nil, nil, nil, nil, 'unknown', nil, e)
      end

      unless line[9].nil?
        new_place(line[9], line[10], line[11], e)
      end

      unless line[19].nil?
        new_place(line[19], line[20], 'recited', e)
      end

      unless line[23].nil?
        new_place(line[23], line[24], line[25], e)
      end
    end
  end

  def date_lookup(value)
    begin
      DateRoleTerms.new('subauthority').search(value).map.first['id']
    rescue
      DateRoleTerms.new('subauthority').search('unknown').map.first['id']
    end
  end

  def place_type_lookup(value)
    begin
      PlaceTypeTerms.new('subauthority').search(value).map.first['id']
    rescue
      PlaceTypeTerms.new('subauthority').search('unknown').map.first['id']
    end
  end

  def place_role_lookup(value)
    begin
      PlaceRoleTerms.new('subauthority').search(value).map.first['id']
    rescue
      PlaceRoleTerms.new('subauthority').search('recited date (for now)').map.first['id']
    end
  end

  def person_role_lookup(value)
    begin
      PersonRoleTerms.new('subauthority').search(value).map.first['id']
    rescue
      PersonRoleTerms.new('subauthority').search('unknown').map.first['id']
    end
  end

  def person_descriptor_lookup(value)
    begin
      DescriptorTerms.new('subauthority').search(value).map.first['id']
    rescue
      DescriptorTerms.new('subauthority').search('unknown').map.first['id']
    end
  end

  def entry_type_lookup
    EntryTypeTerms.new('subauthority').search('unknown').map.first['id']
  end

  def new_entry_date(start, dend, inf, unc, app, role, note, entry)
    date = EntryDate.new
    date.rdftype = date.add_rdf_types
    ee = Entry.where(id: entry).first
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
      s.date = start
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
      dend.gsub('[', '').gsub(']', '').gsub('-00', '')
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
      pl = RelatedPlace.where(id: pid).first
    end

    pl.rdftype = pl.add_rdf_types
    pl.place_as_written = [written]
    pl.place_role = [place_role_lookup(role)]
    pl.place_type = [place_type_lookup(ptype)]
    ee = Entry.where(id: entry).first
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
      pl = RelatedPlace.where(id: pid).first
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
      person.person_related_place = [written]
    else
      person.person_related_place += [written]
    end
    person.save
    ee = Entry.where(id: entry).first
    ee.related_places += [pl]
    ee.save
  end
end
