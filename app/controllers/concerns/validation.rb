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