class NewSolrFieldsController < ApplicationController

  # This code adds new solr fields which are required for the search application
  # Note that this code is called from initializers/active_fedora.rb and overrides the to_solr active_fedora method
  # '_search' fields are added for searching in the interface and are lowercase versions of the actual terms
  # '_new_tesim' fields are created from ids, e.g. for language, so that solr doesn't have to join documents
  # '_label_ssim' fields provide the string and are used for facet counts
  # 'search' is a new fieldType which is defined in the solr schema.xml
  # 'new_tesim' already exists as fieldType 'tesim' in schema.xml
  # 'label_ssim' already exists as fieldType 'ssim' in schema.xml
  def modify_sdoc(sdoc)

    begin

      entry_type_new = get_preflabel_array(sdoc['entry_type_tesim'])
      sdoc['entry_type_new_tesim'] = entry_type_new
      sdoc['entry_type_label_ssim'] = entry_type_new
      sdoc['entry_type_search'] = array_to_lowercase(entry_type_new)

      section_type_new = get_preflabel_array(sdoc['section_type_tesim'])
      sdoc['section_type_new_tesim'] = section_type_new
      sdoc['section_type_label_ssim'] = section_type_new
      sdoc['section_type_search'] = array_to_lowercase(section_type_new)

      sdoc['summary_search'] = array_to_lowercase(sdoc['summary_tesim'])

      sdoc['marginalia_search'] = array_to_lowercase(sdoc['marginalia_tesim'])

      language_new = get_preflabel_array(sdoc['language_tesim'])
      sdoc['language_new_tesim'] = language_new
      sdoc['language_label_ssim'] = language_new
      sdoc['language_search'] = array_to_lowercase(language_new)

      subject_new = get_preflabel_array(sdoc['subject_tesim'])
      sdoc['subject_new_tesim'] = subject_new
      sdoc['subject_search'] = array_to_lowercase(subject_new)
      sdoc['subject_label_ssim'] = subject_new

      sdoc['note_search'] = array_to_lowercase(sdoc['note_tesim'])

      sdoc['editorial_note_search'] = array_to_lowercase(sdoc['editorial_note_tesim'])

      sdoc['is_referenced_by_search'] = array_to_lowercase(sdoc['is_referenced_by_tesim'])

      sdoc['place_as_written_search'] = array_to_lowercase(sdoc['place_as_written_tesim'])

      place_name_authority_new = get_preflabel_array(sdoc['place_same_as_tesim'])
      sdoc['place_same_as_new_tesim'] = place_name_authority_new
      sdoc['place_same_as_label_ssim'] = place_name_authority_new
      sdoc['place_same_as_search'] = array_to_lowercase(place_name_authority_new)

      place_role_new = get_preflabel_array(sdoc['place_role_tesim'])
      sdoc['place_role_new_tesim'] = place_role_new
      sdoc['place_role_label_ssim'] = place_role_new
      sdoc['place_role_search'] = array_to_lowercase(place_role_new)

      place_type_new = get_preflabel_array(sdoc['place_type_tesim'])
      sdoc['place_type_new_tesim'] = place_type_new
      sdoc['place_type_label_ssim'] = place_type_new
      sdoc['place_type_search'] = array_to_lowercase(place_type_new)

      sdoc['place_note_search'] = array_to_lowercase(sdoc['place_note_tesim'])

      sdoc['person_as_written_search'] = array_to_lowercase(sdoc['person_as_written_tesim'])

      person_name_authority_new = get_preflabel_array(sdoc['person_same_as_tesim'])
      sdoc['person_same_as_new_tesim'] = person_name_authority_new
      sdoc['person_same_as_label_ssim'] = person_name_authority_new
      sdoc['person_same_as_search'] = array_to_lowercase(person_name_authority_new)

      person_role_new = get_preflabel_array(sdoc['person_role_tesim'])
      sdoc['person_role_new_tesim'] = person_role_new
      sdoc['person_role_label_ssim'] = person_role_new
      sdoc['person_role_search'] = array_to_lowercase(person_role_new)

      person_descriptor_new = get_preflabel_array(sdoc['person_descriptor_tesim'])
      sdoc['person_descriptor_new_tesim'] = person_descriptor_new
      sdoc['person_descriptor_label_ssim'] = person_descriptor_new
      sdoc['person_descriptor_search'] = array_to_lowercase(person_descriptor_new)

      sdoc['person_descriptor_as_written_search'] = array_to_lowercase(sdoc['person_descriptor_tesim'])

      sdoc['person_note_search'] = array_to_lowercase(sdoc['person_note_tesim'])

      sdoc['person_related_place_search'] = array_to_lowercase(sdoc['person_related_place_tesim'])

      sdoc['person_related_person_search'] = array_to_lowercase(sdoc['person_related_person_tesim'])

      # dates
      date_role_new = get_preflabel_array(sdoc['date_role_tesim'])
      sdoc['date_role_new_tesim'] = date_role_new
      sdoc['date_role_label_ssim'] = date_role_new
      sdoc['date_role_search'] = array_to_lowercase(date_role_new)

      sdoc['date_note_search'] = array_to_lowercase(sdoc['date_note_tesim'])

      sdoc

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end
  end

  # Convert field to lowercase so that all variations can be searched
  # for in the search interface, e.g. 'Paul' 'PAUL', 'paul'
  def array_to_lowercase(old_array)

    begin

      new_array = []

      if old_array != nil
        old_array.each do |t|
          new_array << t.downcase
        end
      end

      return new_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

  # Return name array for the corresponding ids
  def get_preflabel_array(input_array)

    begin

      preflabel_array = []

      if input_array != nil

        input_array.each do |id|
          SolrQuery.new.solr_query('id:' + id, 'preflabel_tesim', 1)['response']['docs'].map do |result|
            preflabel = result['preflabel_tesim'].join
            preflabel_array << preflabel
          end
        end
      end

      return preflabel_array

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

end