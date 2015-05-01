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
    errors = errors + validate_length_and_mandatory_field(entry_params[:entry_no], 'Entry No', SMALL_FIELD)
    errors = errors + validate_length_and_mandatory_field(entry_params[:access_provided_by], 'Access Provided By', MEDIUM_FIELD)
    errors = errors + validate_length_and_mandatory_field(entry_params[:document], 'Document', MEDIUM_FIELD)
    errors = errors + validate_length(entry_params[:document_part], 'Document Part', MEDIUM_FIELD)
    errors = errors + validate_length_and_mandatory_field(entry_params[:folio_type], 'Folio Type', 10)
    errors = errors + validate_length_and_mandatory_field(entry_params[:folio_face_temp], 'Folio Face Temp', 10)
    errors = errors + validate_length(entry_params[:entry_part], 'Entry Part', MEDIUM_FIELD)

    # Note for the nested elements below, e.g. Editorial Note...
    # If the record is empty and an id exists (i.e. the record is already in Fedora), we can delete it with '_destroy=1'
    # Note however that if there isn't an id, the record hasn't been yet been saved in Fedora and we don't want to make '_destroy=1'
    # because the model attribute ':reject_if => 'all_blank' (in entry.rb) won't work!
    #
    # Note that errors are written to the 'errors' variable which are then displayed on the '_form.html.erb' page

    # Editorial Note
    if entry_params[:editorial_notes_attributes] != nil
      entry_params[:editorial_notes_attributes].values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:id] && t[:editorial_note] == ''
            t[:_destroy] = '1'
          end
          errors = errors + get_errors(t[:editorial_note], 'Editorial Note', LARGE_FIELD, '')
        end
      end
    end

    # Format
    if entry_params[:formats_attributes] != nil
      entry_params[:formats_attributes].values.each do |t|
        if t[:id] && t[:format] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_length(t[:format], 'Format', MEDIUM_FIELD)
      end
    end

    # Marginal Note
    if entry_params[:marginal_notes_attributes] != nil
      entry_params[:marginal_notes_attributes].values.each do |t|
        if t[:id] && t[:marginal_note] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_length(t[:marginal_note], 'Marginal Note', LARGE_FIELD)
      end
    end

    # Is Referenced By
    if entry_params[:is_referenced_bies_attributes] != nil
      entry_params[:is_referenced_bies_attributes].values.each do |t|
        if t[:id] && t[:is_referenced_by] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_length(t[:is_referenced_by], 'Is Referenced By', MEDIUM_FIELD)
      end
    end

    # Language
    if entry_params[:languages_attributes] != nil
      entry_params[:languages_attributes].values.each do |t|
        if t[:id] && t[:language] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_length(t[:language], 'Language', 10)
      end
    end

    # Note
    if entry_params[:notes_attributes] != nil
      entry_params[:notes_attributes].values.each do |t|
        if t[:id] && t[:note] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_length(t[:note], 'Note', LARGE_FIELD)
      end
    end

    # Subject
    if entry_params[:subjects_attributes] != nil
      entry_params[:subjects_attributes].values.each do |t|
        if t[:id] && t[:subject] == ''
          t[:_destroy] = '1'
        end
        errors = errors + validate_length(t[:subject], 'Subject', MEDIUM_FIELD)
      end
    end

    return errors

  end

  # Validate field length
  def validate_length(field, field_name, max_length)
    if field.length > max_length
      return field_name + '_Length' + max_length.to_s + '|'
    else
      return ''
    end
  end

  # Validate field length and mandatory field
  def validate_length_and_mandatory_field(field, field_name, max_length)
    if field == ''
      return field_name + '|'
    elsif field.length > max_length
      return field_name + '_Length' + max_length.to_s + '|'
    else
      return ''
    end
  end

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

  def validate_multiple_field(field_params, field, field_name, max_length, error_type)
    if field_params != nil
      field_params.values.each do |t|
        if t[:_destroy] != '1' && t[:_destroy] != 'true'
          if t[:id] && field == ''
            t[:_destroy] = '1'
          end
          errors = errors + get_errors(field, field_name, max_length, error_type)
        end
      end
    end
  end

end