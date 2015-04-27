module Validation

  def validate(entry_params)

    errors = ''

    errors = errors + validate_field_mandatory(entry_params[:entry_no], 'Entry No', 10)
    errors = errors + validate_field_mandatory(entry_params[:access_provided_by], 'Access Provided By', 100)
    errors = errors + validate_field_mandatory(entry_params[:document], 'Document', 100)
    errors = errors + validate_field(entry_params[:document_part], 'Document Part', 100)
    errors = errors + validate_field_mandatory(entry_params[:folio_type], 'Folio Type', 100)
    errors = errors + validate_field_mandatory(entry_params[:folio_face_temp], 'Folio Face Temp', 100)
    errors = errors + validate_field(entry_params[:entry_part], 'Entry Part', 100)

    # Editorial Note
    if entry_params[:editorial_notes_attributes] != nil
      entry_params[:editorial_notes_attributes].values.each do |t|
        if t[:editorial_note] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_field(t[:editorial_note], 'Editorial Note', 1000)
      end
    end

    # Format
    if entry_params[:formats_attributes] != nil
      entry_params[:formats_attributes].values.each do |t|
        if t[:format] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_field(t[:format], 'Format', 100)
      end
    end

    # Marginal Note
    if entry_params[:marginal_notes_attributes] != nil
      entry_params[:marginal_notes_attributes].values.each do |t|
        if t[:marginal_note] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_field(t[:marginal_note], 'Marginal Note', 1000)
      end
    end

    # Is Referenced By
    if entry_params[:is_referenced_bies_attributes] != nil
      entry_params[:is_referenced_bies_attributes].values.each do |t|
        if t[:is_referenced_by] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_field(t[:is_referenced_by], 'Is Referenced By', 100)
      end
    end

    # Language
    if entry_params[:languages_attributes] != nil
      entry_params[:languages_attributes].values.each do |t|
        if t[:language] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_field(t[:language], 'Language', 100)
      end
    end

    # Note
    if entry_params[:notes_attributes] != nil
      entry_params[:notes_attributes].values.each do |t|
        if t[:note] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_field(t[:note], 'Note', 1000)
      end
    end

    # Note: in the following error code (for date, person and place), check that a value other than date_type exists because otherwise the date element will disappear but the error message will be displayed

    # Date
    if entry_params[:entry_dates_attributes] != nil

      date_set = Set.new()

      entry_params[:entry_dates_attributes].values.each do |t|

        if t[:date_type] == '' && t[:date_as_written] == '' && t[:date_span] == '' && t[:date_certainty] == '' && t[:date] == '' && t[:note] == ''
          puts "HERE101"
          t[:_destroy] = '1'
        else

          errors = errors + validate_field(t[:date_type], 'Date Type', 100)
          errors = errors + validate_field(t[:date_as_written], 'Date As Written', 100)
          errors = errors + validate_field(t[:date_span], 'Date Span', 100)
          errors = errors + validate_field(t[:date_certainty], 'Date Certainty', 100)
          errors = errors + validate_field(t[:date], 'Date', 100)
          errors = errors + validate_field(t[:note], 'Date Note', 1000)

          if t[:date_type] == '' && (t[:date_as_written] != '' || t[:date_span] != '' || t[:date_certainty] != '' || t[:date] != '' || t[:note] != '')
            date_set.add('Date Type')
          end

          if t[:date_as_written] == '' && (t[:date_type] != '' || t[:date_span] != '' || t[:date_certainty] != '' || t[:date] != '' || t[:note] != '')
            date_set.add('Date As Written')
          end

          if t[:date_span] == '' && (t[:date_type] != '' || t[:date_as_written] != '' || t[:date_certainty] != '' || t[:date] != '' || t[:note] != '')
            date_set.add('Date Span')
          end

          if t[:date] == '' && (t[:date_type] != '' || t[:date_as_written] != '' || t[:date_span] != '' || t[:date_certainty] != '' || t[:note] != '')
            date_set.add('Date')
          end
        end

        # Return mandatory field errors
        date_set.each do |ds|
          errors = errors + ds + '|'
        end
      end
    end

    # Person
    if entry_params[:people_attributes] != nil

      entry_params[:people_attributes].values.each do |t|

        person_set = Set.new()

        name_as_written = ''
        role_name = ''
        occupation = ''
        status = ''
        qualification = ''

        #name_as_written
        if t[:name_as_writtens_attributes] != nil
          t[:name_as_writtens_attributes].values.each do |tt|
            if tt[:name_as_written] != ''
              errors = errors + validate_field(tt[:name_as_written], 'Name As Written', 100)
              name_as_written = 'true'
              break
            end
          end
        end

        # role_name
        if t[:role_names_attributes] != nil
          t[:role_names_attributes].values.each do |tt|
            if tt[:role_name] != ''
              errors = errors + validate_field(tt[:role_name], 'Role Name', 100)
              role_name = 'true'
              break
            end
          end
        end

        errors = errors + validate_field(t[:note], 'Person Note', 1000)
        errors = errors + validate_field(t[:age], 'Age', 100)
        errors = errors + validate_field(t[:gender], 'Gender', 10)
        errors = errors + validate_field(t[:name_authority], 'Name Authority', 100)

        # occupation
        if t[:occupations_attributes] != nil
          t[:occupations_attributes].values.each do |tt|
            if tt[:occupation_name] != ''
              errors = errors + validate_field(tt[:occupation_name], 'Occupation', 100)
              occupation = 'true'
              break
            end
          end
        end

        # status
        if t[:statuses_attributes] != nil
          t[:statuses_attributes].values.each do |tt|
            if tt[:status_name] != ''
              errors = errors + validate_field(tt[:status_name], 'Status', 100)
              status = 'true'
              break
            end
          end
        end

        # qualification
        if t[:qualifications_attributes] != nil
          t[:qualifications_attributes].values.each do |tt|
            if tt[:qualification_name] != ''
              errors = errors + validate_field(tt[:qualification_name], 'Qualification', 100)
              qualification = 'true'
              break
            end
          end
        end


        # Check name_as_written mandatory fields
        if name_as_written == '' && (role_name != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || t[:name_authority] != '' || occupation != '' || status != '' || qualification != '')
          person_set.add('Name As Written')
        end

        # Check role_name mandatory fields
        if role_name == '' && (name_as_written != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || t[:name_authority] != '' || occupation != '' || status != '' || qualification != '')
          person_set.add('Role Name')
        end

        # Check name_authority mandatory fields
        if t[:name_authority] == '' && (name_as_written != '' || role_name != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || occupation != '' || status != '' || qualification != '')
          person_set.add('Name Authority')
        end

        if person_set.empty?
          puts "HERE1"
          # If there are no errors and everything is empty, delete the element
          if name_as_written == ''
            #puts "HERE2"
            t[:_destroy] = '1'
          end
        else
          person_set.each do |ps|
            errors = errors + ps + '|'
          end
        end
      end
    end

    # Place
    if entry_params[:places_attributes] != nil

      place_set = Set.new()

      entry_params[:places_attributes].values.each do |t|

        place_as_written = ''
        additional_type = ''
        place_note = ''

        # place_as_written
        if t[:place_as_writtens_attributes] != nil
          t[:place_as_writtens_attributes].values.each do |tt|
            if tt[:place_as_written] != ''
              errors = errors + validate_field(tt[:place_as_written], 'Place As Written', 100)
              place_as_written = 'true'
              break
            end
          end
        end

        # additional_type
        if t[:place_additional_types_attributes] != nil
          t[:place_additional_types_attributes].values.each do |tt|
            if tt[:additional_type] != ''
              puts "ADDITIONAL TYPE!!!"
              errors = errors + validate_field(tt[:additional_type], 'Additional Type', 100)
              additional_type = 'true'
              break
            end
          end
        end

        errors = errors + validate_field(t[:place_authority], 'Place Authority', 100)

        # place_note
        if t[:place_notes_attributes] != nil
          t[:place_notes_attributes].values.each do |tt|
            if tt[:place_note] != ''
              errors = errors + validate_field(tt[:place_note], 'Place Note', 1000)
              place_note = 'true'
              break
            end
          end
        end

        # Check place_as_written
        if place_as_written == '' && (additional_type != '' || t[:place_authority] != '' || place_note != '')
          place_set.add('Place As Written')
        end

        # Check place_authority
        if t[:place_authority] == '' && (place_as_written != '' || additional_type != '' || place_note != '')
          place_set.add('Place Authority')
        end

      end

      place_set.each do |ps|
        errors = errors + ps + '|'
      end
    end

    # Subject
    if entry_params[:subjects_attributes] != nil
      entry_params[:subjects_attributes].values.each do |t|
        if t[:subject] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_field(t[:subject], 'Subject', 100)
      end
    end

    return errors
  end

  def validate_field(entry, entry_name, max_length)
    #puts entry.inspect + ", " + entry.length.to_s + ", " + entry_name + '_Length' + max_length.to_s + '|'
    if entry.length > max_length
      return entry_name + '_Length' + max_length.to_s + '|'
    else
      return ''
    end
  end

  def validate_field_mandatory(entry, entry_name, max_length)
    if entry == ''
      return entry_name + '|'
    elsif entry.length > max_length
      return entry_name + '_Length' + max_length.to_s + '|'
    else
      return ''
    end
  end

end