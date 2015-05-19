module Validation

  # Permissible field lengths for form elements
  SMALL_FIELD = 2
  MEDIUM_FIELD = 2
  LARGE_FIELD = 2

  # Check for mandatory fields and field length
  # Build up a string called 'errors' which stores each error delimited by a '|'
  # Note - a check is made to see if the field is empty - if so, make '_destroy = 1' so that the field is deleted in Fedora
  # Note - 'M' checks for a mandatory field
  def validate(entry_params)

    errors = ''

    # Check single fields, i.e. those which do not have a '+' button
    errors = errors + get_errors(entry_params[:entry_no], 'Entry No', SMALL_FIELD, 'M')
    errors = errors + get_errors(entry_params[:access_provided_by], 'Access Provided By', MEDIUM_FIELD, 'M')
    errors = errors + get_errors(entry_params[:document], 'Document', MEDIUM_FIELD, 'M')
    errors = errors + get_errors(entry_params[:document_part], 'Document Part', MEDIUM_FIELD, '')
    errors = errors + get_errors(entry_params[:folio_type], 'Folio Type', 10, 'M')
    errors = errors + get_errors(entry_params[:folio_face_temp], 'Folio Face Temp', 10, 'M')
    errors = errors + get_errors(entry_params[:entry_part], 'Entry Part', MEDIUM_FIELD, '')

    # Editorial Note
    # If the record is empty and an id exists (i.e. the record is already in Fedora), we can delete it with '_destroy=1'
    # Note however that if there isn't an id, the record hasn't been yet been saved in Fedora and we don't want to make '_destroy=1'
    # because the model attribute ':reject_if => 'all_blank' (in entry.rb) won't work! The same goes for Format, Marginal Note, etc
    if entry_params[:editorial_notes_attributes] != nil
      entry_params[:editorial_notes_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true' # This code bypasses validation checking if the field is hidden (otherwise it will display any errors for the hidden element!)
          if t[:id] && t[:editorial_note] == ''
            t[:_destroy] = '1'
          end
          errors = errors + get_errors(t[:editorial_note], 'Editorial Note', LARGE_FIELD, '') # errors are written to the 'errors' variable which is displayed on the '_form.html.erb' page
        end
      end
    end

    # Format
    if entry_params[:formats_attributes] != nil
      entry_params[:formats_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
        if t[:id] && t[:format] == ''
          t[:_destroy] = '1'
        end
        errors = errors + get_errors(t[:format], 'Format', MEDIUM_FIELD, '')
        end
      end
    end

    # Marginal Note
    if entry_params[:marginal_notes_attributes] != nil
      entry_params[:marginal_notes_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
        if t[:id] && t[:marginal_note] == ''
          t[:_destroy] = '1'
        end
        errors = errors + get_errors(t[:marginal_note], 'Marginal Note', LARGE_FIELD, '')
          end
      end
    end

    # Is Referenced By
    if entry_params[:is_referenced_bies_attributes] != nil
      entry_params[:is_referenced_bies_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
        if t[:id] && t[:is_referenced_by] == ''
          t[:_destroy] = '1'
        end
        errors = errors + get_errors(t[:is_referenced_by], 'Is Referenced By', MEDIUM_FIELD, '')
          end
      end
    end

    # Language
    if entry_params[:languages_attributes] != nil
      entry_params[:languages_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
        if t[:id] && t[:language] == ''
          t[:_destroy] = '1'
        end
        errors = errors + get_errors(t[:language], 'Language', 10, '')
          end
      end
    end

    # Note
    if entry_params[:notes_attributes] != nil
      entry_params[:notes_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
        if t[:id] && t[:note] == ''
          t[:_destroy] = '1'
        end
        errors = errors + get_errors(t[:note], 'Note', LARGE_FIELD, '')
          end
      end
    end

    # Subject
    if entry_params[:subjects_attributes] != nil
      entry_params[:subjects_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
        if t[:id] && t[:subject] == ''
          t[:_destroy] = '1'
        end
        errors = errors + get_errors(t[:subject], 'Subject', MEDIUM_FIELD, '')
          end
      end
    end

    # Date
    if entry_params[:entry_dates_attributes] != nil

      # Iterate over the date elements
      entry_params[:entry_dates_attributes].values.each do |t|

        if t[:_destroy] != '1' && t[:_destroy] != 'true'

          # If all date fields are empty, do not have to validate - just delete the date
          if t[:id] && t[:date_type] == '' && t[:date_as_written] == '' && t[:date_span] == '' && t[:date_certainty] == '' && t[:date] == '' && t[:note] == ''

            t[:_destroy] = '1'

          else
            # Check the field length of date_type, date_as_written, date_span, date_certainty, date and date_note
            # Note that we don't check for mandatory fields here but in the code below
            errors = errors + get_errors(t[:date_type], 'Date Type', 20, '')
            errors = errors + get_errors(t[:date_as_written], 'Date As Written', MEDIUM_FIELD, '')
            errors = errors + get_errors(t[:date_span], 'Date Span', MEDIUM_FIELD, '')
            errors = errors + get_errors(t[:date_certainty], 'Date Certainty', MEDIUM_FIELD, '')
            errors = errors + get_errors(t[:date], 'Date', MEDIUM_FIELD, '')
            errors = errors + get_errors(t[:note], 'Date Note', LARGE_FIELD, '')

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

        # Only validate the person if the delete icon hasn't been clicked
        if t[:_destroy] != '1' && t[:_destroy] != 'true'

          local_errors = ''
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
                local_errors = local_errors + get_errors(tt[:name_as_written], 'Name As Written', MEDIUM_FIELD, '')
                break
              end
            end
          end

          # Check if any 'role_name' fields exist and validate the length
          if t[:role_names_attributes] != nil
            t[:role_names_attributes].values.each do |tt|
              if tt[:role_name] != ''
                role_name = 'true'
                local_errors = local_errors + get_errors(tt[:role_name], 'Role Name', MEDIUM_FIELD, '')
                break
              end
            end
          end

          # Check field lengths of person_note, age, gender and name_authority
          errors = errors + get_errors(t[:note], 'Person Note', LARGE_FIELD, '')
          errors = errors + get_errors(t[:age], 'Age', MEDIUM_FIELD, '')
          errors = errors + get_errors(t[:gender], 'Gender', SMALL_FIELD, '')
          errors = errors + get_errors(t[:name_authority], 'Name Authority', MEDIUM_FIELD, '')

          # Check if any 'occupation' fields exist and validate the length
          if t[:occupations_attributes] != nil
            t[:occupations_attributes].values.each do |tt|
              if tt[:occupation_name] != ''
                occupation = 'true'
                local_errors = local_errors + get_errors(tt[:occupation_name], 'Occupation', MEDIUM_FIELD, '')
                break
              end
            end
          end

          # Check if any 'status' fields exist and validate the length
          if t[:statuses_attributes] != nil
            t[:statuses_attributes].values.each do |tt|
              if tt[:status_name] != ''
                status = 'true'
                local_errors = local_errors + get_errors(tt[:status_name], 'Status', MEDIUM_FIELD, '')
                break
              end
            end
          end

          # Check any 'qualification' fields exist and validate the length
          if t[:qualifications_attributes] != nil
            t[:qualifications_attributes].values.each do |tt|
              if tt[:qualification_name] != ''
                qualification = 'true'
                local_errors = local_errors + get_errors(tt[:qualification_name], 'Qualification', MEDIUM_FIELD, '')
                break
              end
            end
          end

          # Check mandatory field 'name_as_written' exists (if other fields exist)
          if name_as_written == '' && (role_name != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || t[:name_authority] != '' || occupation != '' || status != '' || qualification != '')
            local_errors = local_errors + 'Name As Written' + '|'
          end

          # Check mandatory field 'role_name' exists (if other fields exist)
          if role_name == '' && (name_as_written != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || t[:name_authority] != '' || occupation != '' || status != '' || qualification != '')
            local_errors = local_errors + 'Role Name' + '|'
          end

          # Check mandatory field 'name_authority' exists (if other fields exist)
          if t[:name_authority] == '' && (name_as_written != '' || role_name != '' || t[:note] != '' || t[:age] != '' || t[:gender] != '' || occupation != '' || status != '' || qualification != '')
            local_errors = local_errors + 'Name Authority' + '|'
          end

          # If the data has been already been saved in Fedora and all fields are empty, just remove the entry (some of the code above will therefore be redundant - might look at a better way to do this later on)
          # Note that this code checks that an id exists because we don't want to make '_destroy=1' if the user has added a blank field (see Editorial Note comments above)
          if t[:id] && name_as_written == '' && role_name == '' && t[:note] == '' && t[:age] == '' && t[:gender] == '' && t[:name_authority] == '' && occupation == '' && status == '' && qualification == ''
            t[:_destroy] = '1'
          else
            errors = errors + local_errors
          end

        end
      end
    end

    return errors

  end


  # Check for field length and mandatory field errors
  # 'M' checks for a mandatory field
  def get_errors(field, field_name, max_length, error_type)
    # Check if it is a mandatory field
    if error_type == 'M' && field == ''
      return field_name + '|'
    end
    # Check the field doesn't exceed the maximum length
    if field.length > max_length
        return field_name + '_Length' + max_length.to_s + '|'
      else
        return ''
    end
  end
end