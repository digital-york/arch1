module Validation

  # Permissible field lengths for form elements
  SMALL_FIELD = 2
  MEDIUM_FIELD = 2
  LARGE_FIELD = 2

  # Check for mandatory fields and field length
  # Build up a string called 'errors' which stores each error delimited by a '|'
  # Note that a check is made to see if the field is empty - if so, make '_destroy = 1' so that the field is deleted in Fedora
  def validate(entry_params)

    errors = ''

    # Check single fields, i.e. those which do not have a '+' button
    errors = errors + validate_field_mandatory(entry_params[:entry_no], 'Entry No', SMALL_FIELD)
    errors = errors + validate_field_mandatory(entry_params[:access_provided_by], 'Access Provided By', MEDIUM_FIELD)
    errors = errors + validate_field_mandatory(entry_params[:document], 'Document', MEDIUM_FIELD)
    errors = errors + validate_field(entry_params[:document_part], 'Document Part', MEDIUM_FIELD)
    errors = errors + validate_field_mandatory(entry_params[:folio_type], 'Folio Type', 10)
    errors = errors + validate_field_mandatory(entry_params[:folio_face_temp], 'Folio Face Temp', 10)
    errors = errors + validate_field(entry_params[:entry_part], 'Entry Part', MEDIUM_FIELD)

    # Editorial Note
    if entry_params[:editorial_notes_attributes] != nil
      entry_params[:editorial_notes_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true' # Skip the validation step if '_destroy' = 1 or '_destroy' = true because the element is hidden
          if t[:editorial_note] == ''
            t[:_destroy] = '1' # Make '_destroy' = 1 if the field is empty because we want it to be deleted from Fedora
          end
          errors = errors + validate_field(t[:editorial_note], 'Editorial Note', LARGE_FIELD) # Write any errors to the 'errors' variable which is used to display errors on the '_form.html.erb' page
        end
      end
    end

    # Format
    if entry_params[:formats_attributes] != nil
      entry_params[:formats_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:format] == ''
            t[:_destroy] = '1'
          end
          errors = errors + validate_field(t[:format], 'Format', MEDIUM_FIELD)
        end
      end
    end

    # Marginal Note
    if entry_params[:marginal_notes_attributes] != nil
      entry_params[:marginal_notes_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:marginal_note] == ''
            t[:_destroy] = '1'
          end
          errors = errors + validate_field(t[:marginal_note], 'Marginal Note', LARGE_FIELD)
        end
      end
    end

    # Is Referenced By
    if entry_params[:is_referenced_bies_attributes] != nil
      entry_params[:is_referenced_bies_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:is_referenced_by] == ''
            t[:_destroy] = '1'
          end
          errors = errors + validate_field(t[:is_referenced_by], 'Is Referenced By', MEDIUM_FIELD)
        end
      end
    end

    # Language
    if entry_params[:languages_attributes] != nil
      entry_params[:languages_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:language] == ''
            t[:_destroy] = '1'
          end
          errors = errors + validate_field(t[:language], 'Language', 10)
        end
      end
    end

    # Note
    if entry_params[:notes_attributes] != nil
      entry_params[:notes_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:note] == ''
            t[:_destroy] = '1'
          end
          errors = errors + validate_field(t[:note], 'Note', LARGE_FIELD)
        end
      end
    end

    # Note: in the following error code (for date, person and place), check that a value other than date_type exists because otherwise the date element will disappear but the error message will be displayed

    # Date
    if entry_params[:entry_dates_attributes] != nil

      # Iterate over the date elements
      entry_params[:entry_dates_attributes].values.each do |t|

        # If all date fields are empty, do not have to validate - just delete the date
        if t[:date_type] == '' && t[:date_as_written] == '' && t[:date_span] == '' && t[:date_certainty] == '' && t[:date] == '' && t[:note] == ''
          t[:_destroy] = '1'

        # Else validate the date fields
        else

          # Only validate the date if the remove button hasn't been clicked
          if t[:_destroy] != '1' && t[:_destroy] != 'true'

            # Check the field length of date_type, date_as_written, date_span, date_certainty, date and date_note
            errors = errors + validate_field(t[:date_type], 'Date Type', 20)
            errors = errors + validate_field(t[:date_as_written], 'Date As Written', MEDIUM_FIELD)
            errors = errors + validate_field(t[:date_span], 'Date Span', MEDIUM_FIELD)
            errors = errors + validate_field(t[:date_certainty], 'Date Certainty', MEDIUM_FIELD)
            errors = errors + validate_field(t[:date], 'Date', MEDIUM_FIELD)
            errors = errors + validate_field(t[:note], 'Date Note', LARGE_FIELD)

            # Check mandatory field 'data_type' exists
            if t[:date_type] == '' && (t[:date_as_written] != '' || t[:date_span] != '' || t[:date_certainty] != '' || t[:date] != '' || t[:note] != '')
              errors = errors + 'Date Type' + '|'
            end

            # Check mandatory field 'date_as_written' exists
            if t[:date_as_written] == '' && (t[:date_type] != '' || t[:date_span] != '' || t[:date_certainty] != '' || t[:date] != '' || t[:note] != '')
              errors = errors + 'Date As Written' + '|'
            end

            # Check mandatory field 'date_span' exists
            if t[:date_span] == '' && (t[:date_type] != '' || t[:date_as_written] != '' || t[:date_certainty] != '' || t[:date] != '' || t[:note] != '')
              errors = errors + 'Date Span' + '|'
            end

            # Check mandatory field 'date' exists
            if t[:date] == '' && (t[:date_type] != '' || t[:date_as_written] != '' || t[:date_span] != '' || t[:date_certainty] != '' || t[:note] != '')
              errors = errors + 'Date' + '|'
            end
          end
        end
      end
    end

    # Person
    if entry_params[:people_attributes] != nil

      # Iterate over the people elements
      entry_params[:people_attributes].values.each do |t|

        # Only validate the person if the remove button hasn't been clicked
        if t[:_destroy] != '1' && t[:_destroy] != 'true'

          name_as_written = ''
          role_name = ''
          occupation = ''
          status = ''
          qualification = ''

          # Check if any 'name_as_written' fields exist and validate the length
          if t[:name_as_writtens_attributes] != nil
            t[:name_as_writtens_attributes].values.each do |tt|
              if tt[:name_as_written] != ''
                name_as_written = 'true'
                errors = errors + validate_field(tt[:name_as_written], 'Name As Written', MEDIUM_FIELD)
                break
              end
            end
          end

          # Check if any 'role_name' fields exist and validate the length
          if t[:role_names_attributes] != nil
            t[:role_names_attributes].values.each do |tt|
              if tt[:role_name] != ''
                role_name = 'true'
                errors = errors + validate_field(tt[:role_name], 'Role Name', MEDIUM_FIELD)
                break
              end
            end
          end

          # Check field lengths of person_note, age, gender and name_authority
          errors = errors + validate_field(t[:note], 'Person Note', LARGE_FIELD)
          errors = errors + validate_field(t[:age], 'Age', MEDIUM_FIELD)
          errors = errors + validate_field(t[:gender], 'Gender', SMALL_FIELD)
          errors = errors + validate_field(t[:name_authority], 'Name Authority', MEDIUM_FIELD)

          # Check if any 'occupation' fields exist and validate the length
          if t[:occupations_attributes] != nil
            t[:occupations_attributes].values.each do |tt|
              if tt[:occupation_name] != ''
                occupation = 'true'
                errors = errors + validate_field(tt[:occupation_name], 'Occupation', MEDIUM_FIELD)
                break
              end
            end
          end

          # Check if any 'status' fields exist and validate the length
          if t[:statuses_attributes] != nil
            t[:statuses_attributes].values.each do |tt|
              if tt[:status_name] != ''
                status = 'true'
                errors = errors + validate_field(tt[:status_name], 'Status', MEDIUM_FIELD)
                break
              end
            end
          end

          # Check if any 'qualification' fields exist and validate the length
          if t[:qualifications_attributes] != nil
            t[:qualifications_attributes].values.each do |tt|
              if tt[:qualification_name] != ''
                qualification = 'true'
                errors = errors + validate_field(tt[:qualification_name], 'Qualification', MEDIUM_FIELD)
                break
              end
            end
          end

          # Check mandatory field 'name_as_written' exists (if other fields exist)
          if name_as_written == '' && (role_name != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || t[:name_authority] != '' || occupation != '' || status != '' || qualification != '')
            errors = errors + 'Name As Written' + '|'
          end

          # Check mandatory field 'role_name' exists (if other fields exist)
          if role_name == '' && (name_as_written != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || t[:name_authority] != '' || occupation != '' || status != '' || qualification != '')
            errors = errors + 'Role Name' + '|'
          end

          # Check mandatory field 'name_authority' exists (if other fields exist)
          if t[:name_authority] == '' && (name_as_written != '' || role_name != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || occupation != '' || status != '' || qualification != '')
            errors = errors + 'Name Authority' + '|'
          end
        end
      end
    end

    # Place
    if entry_params[:places_attributes] != nil

      # Iterate over the place elements
      entry_params[:places_attributes].values.each do |t|

        # Only validate the place if the remove button hasn't been clicked
        if t[:_destroy] != '1' && t[:_destroy] != 'true'

          place_as_written = ''
          additional_type = ''
          place_note = ''

          # Check if any 'place_as_written' fields exist and validate the length
          if t[:place_as_writtens_attributes] != nil
            t[:place_as_writtens_attributes].values.each do |tt|
              if tt[:place_as_written] != ''
                place_as_written = 'true'
                errors = errors + validate_field(tt[:place_as_written], 'Place As Written', MEDIUM_FIELD)
                break
              end
            end
          end

          # Check if any 'additional_type' fields exist and validate the length
          if t[:place_additional_types_attributes] != nil
            t[:place_additional_types_attributes].values.each do |tt|
              if tt[:additional_type] != ''
                additional_type = 'true'
                errors = errors + validate_field(tt[:additional_type], 'Additional Type', MEDIUM_FIELD)
                break
              end
            end
          end

          # Check field length of 'place_authority'
          errors = errors + validate_field(t[:place_authority], 'Place Authority', MEDIUM_FIELD)

          # Check if 'place_note' exists and validate the length
          if t[:place_notes_attributes] != nil
            t[:place_notes_attributes].values.each do |tt|
              if tt[:place_note] != ''
                place_note = 'true'
                errors = errors + validate_field(tt[:place_note], 'Place Note', LARGE_FIELD)
                break
              end
            end
          end

          # Check mandatory field 'place_as_written' exists (if other fields exist)
          if place_as_written == '' && (additional_type != '' || t[:place_authority] != '' || place_note != '')
            errors = errors + 'Place As Written' + '|'
          end

          # Check mandatory field 'place_authority' exists (if other fields exist)
          if t[:place_authority] == '' && (place_as_written != '' || additional_type != '' || place_note != '')
            errors = errors + 'Place Authority' + '|'
          end
        end
      end
    end

    # Subject
    if entry_params[:subjects_attributes] != nil
      entry_params[:subjects_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:subject] == ''
            t[:_destroy] = '1'
          end
          errors = errors + validate_field(t[:subject], 'Subject', MEDIUM_FIELD)
        end
      end
    end

    return errors
  end

  # Validate field length
  def validate_field(field, field_name, max_length)
    if field.length > max_length
      return field_name + '_Length' + max_length.to_s + '|'
    else
      return ''
    end
  end

  # Validate field length and mandatory field
  def validate_field_mandatory(field, field_name, max_length)
    if field == ''
      return field_name + '|'
    elsif field.length > max_length
      return field_name + '_Length' + max_length.to_s + '|'
    else
      return ''
    end
  end

end