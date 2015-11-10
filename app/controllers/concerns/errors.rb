module Errors

# Commented all this out because not sure if we're going to check for any errors on the server side now
# This is because of the difficulties of going back to the page with the correct dates, places and people open
# and because we would need some code to change ActiveFedora code into ActiveRecord code

=begin
# Permissible field lengths for form elements
SMALL_FIELD = 200
MEDIUM_FIELD = 200
LARGE_FIELD = 200

# Check for mandatory fields and field length
# Build up a string called 'errors' which stores each error delimited by a '|'
# Note - a check is made to see if the field is empty - if so, make '_destroy = 1' so that the field is deleted in Fedora
# Note - 'M' checks for a mandatory field
def check_for_errors(entry_params)

  errors = ''

  errors = errors + get_errors(entry_params[:entry_no], 'Entry No', SMALL_FIELD, 'M')
  errors = errors + get_errors(entry_params[:entry_type], 'Entry Type', MEDIUM_FIELD, '')
  errors = errors + get_errors(entry_params[:summary], 'Summary', MEDIUM_FIELD, '')
  errors = errors + get_multi_field_errors(entry_params[:section_type], 'Section Type', MEDIUM_FIELD)
  errors = errors + get_multi_field_errors(entry_params[:marginalia], 'Marginalia', MEDIUM_FIELD)
  errors = errors + get_multi_field_errors(entry_params[:language], 'Language', MEDIUM_FIELD)
  errors = errors + get_multi_field_errors(entry_params[:subject], 'Subject', MEDIUM_FIELD)
  errors = errors + get_multi_field_errors(entry_params[:note], 'Note', MEDIUM_FIELD)
  errors = errors + get_multi_field_errors(entry_params[:editorial_note], 'Editorial Note', MEDIUM_FIELD)
  errors = errors + get_multi_field_errors(entry_params[:is_referenced_by], 'Referenced By', MEDIUM_FIELD)

  # Validate related places
  related_places_params = entry_params[:related_places_attributes]

  if related_places_params != nil

    related_places_params.values.each do |related_place|

      #if related_place[:_destroy] != nil and related_place[:_destroy] != '1'
      errors = errors + get_errors(related_place[:place_same_as], 'Place Same As', SMALL_FIELD, '')
      errors = errors + get_multi_field_errors(related_place[:place_as_written], 'Place As Written', MEDIUM_FIELD)
      errors = errors + get_multi_field_errors(related_place[:place_role], 'Place Role', MEDIUM_FIELD)
      errors = errors + get_multi_field_errors(related_place[:place_type], 'Place Type', MEDIUM_FIELD)
      errors = errors + get_multi_field_errors(related_place[:place_note], 'Place Note', MEDIUM_FIELD)
      #end
    end
  end

  # Validate related people
  related_person_groups_params = entry_params[:related_person_groups_attributes]

  if related_person_groups_params != nil

    related_person_groups_params.values.each do |related_person|

      #if related_person[:_destroy] != nil and related_person[:_destroy] != '1'
      errors = errors + get_errors(related_person[:person_same_as], 'Person Same As', SMALL_FIELD, '')
      errors = errors + get_multi_field_errors(related_person[:person_as_written], 'Person As Written', MEDIUM_FIELD)
      errors = errors + get_errors(related_person[:person_gender], 'Person Gender', SMALL_FIELD, '')
      errors = errors + get_multi_field_errors(related_person[:person_role], 'Person Role', MEDIUM_FIELD)
      errors = errors + get_multi_field_errors(related_person[:person_descriptor], 'Person Descriptor', MEDIUM_FIELD)
      errors = errors + get_multi_field_errors(related_person[:person_note], 'Person Note', MEDIUM_FIELD)
      errors = errors + get_multi_field_errors(related_person[:person_related_place], 'Person Related Place', MEDIUM_FIELD)
      #end
    end
  end

  return errors

end

def get_multi_field_errors(multi_field, field_name, max_size)
  errors = ''
  if multi_field != nil && multi_field != ''
    multi_field.each do |field|
      errors = errors + get_errors(field, field_name, max_size, '')
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
=end

end