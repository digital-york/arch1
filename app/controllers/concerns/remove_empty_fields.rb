module RemoveEmptyFields

  # ********** Notes on removing multi-value (array) fields and Date, Place, Person blocks **********
  # Removing Level 1 multi-value fields, e.g. 'Summary':
  #   Note that in all the four cases below, empty values in the form are submitted as empty arrays [''] and these have to be removed (see the remove_empty_array_fields function), otherwise an empty field is submitted to Fedora
  #   Note also that when the 'x' delete icon is clicked, a value of '' is entered into the corresponding multi-value field so it is essentially the same as leaving a field blank or removing the text, etc
  #
  #   Case 1: add field and delete with 'x' button => nothing saved to Fedora
  #   Case 2: add field and remove text to leave the field empty => nothing saved to Fedora
  #   Case 3: add field, save, then remove text to leave the field empty => Fedora value overwritten with nothing
  #   Case 4: add field, save, then delete with 'x' button => Fedora value overwritten with nothing
  #
  # Removing Date, Place, Person blocks:
  #    Multi-value fields within Date, Person, Place blocks work the same as in the Level 1 cases but there are further steps to delete the blocks. Note that when a removes a date, place or person wby clicking the 'x' button, the block is hidden and a hidden field ('_destroy' = '1') is passed
  #    to the controller when the form is submitted. There are three cases:
  #
  #    Case 1: add place, fill-in one or more of the fields, remove block by clicking the 'x' button => all the fields are set to '' (see function remove_empty_place_blocks) and nothing is saved to Fedora
  #    Case 2: add place, fill-in one or more of the fields, save, remove block by clicking the 'x' button => '_destroy' = '1' is added to the entry (using jquery) and this automatically removes the block from Fedora
  #    Case 3: add place, fill-in one or more of the fields, save, remove text to leave all fields empty, etc => '_destroy' = '1' is added to the entry (see function remove empty_place_blocks) and this automatically removes the block from Fedora
  #
  # ********** End of Notes **********

  # Remove empty multi-value (array) fields and empty date, place and person blocks (this is quite complicated - please see notes above!)
  def remove_empty_fields(entry_params)
    remove_empty_array_fields(entry_params)
    remove_empty_date_blocks(entry_params)
    remove_empty_place_blocks(entry_params)
    remove_empty_person_blocks(entry_params)
  end

  # Remove multi-value fields (i.e. arrays) such as 'Summary' and 'As Written'
  # This is required because empty array fields are submitted as [''] and an empty field will be added to Fedora
  # Note that for the multi-value fields in Place and Person, I've used the full entry_params values rather than using the index variables, e.g. 'related_place'
  # because the index variable is class Array rather than ActionController::Parameters (please see the Rails section of the wiki for more info on form parameters)
  def remove_empty_array_fields(entry_params)

    # Doesn't seem to be necessary now - fixed by the new activefedora release (9.0.6)??
    #entry_params[:section_type] = remove_empty_array_fields2(entry_params[:section_type])
    #entry_params[:marginalia] = remove_empty_array_fields2(entry_params[:marginalia])
    #entry_params[:language] = remove_empty_array_fields2(entry_params[:language])
    #entry_params[:subject] = remove_empty_array_fields2(entry_params[:subject])
    #entry_params[:note] = remove_empty_array_fields2(entry_params[:note])
    #entry_params[:editorial_note] = remove_empty_array_fields2(entry_params[:editorial_note])
    #entry_params[:is_referenced_by] = remove_empty_array_fields2(entry_params[:is_referenced_by])

    # Remove empty multi-value fields (place)
    if entry_params[:related_places_attributes] != nil
      entry_params[:related_places_attributes].each_with_index do |related_place, index|
        entry_params[:related_places_attributes][index.to_s][:place_as_written] = remove_empty_array_fields2(entry_params[:related_places_attributes][index.to_s][:place_as_written])
        entry_params[:related_places_attributes][index.to_s][:place_role] = remove_empty_array_fields2(entry_params[:related_places_attributes][index.to_s][:place_role])
        entry_params[:related_places_attributes][index.to_s][:place_type] = remove_empty_array_fields2(entry_params[:related_places_attributes][index.to_s][:place_type])
        entry_params[:related_places_attributes][index.to_s][:place_note] = remove_empty_array_fields2(entry_params[:related_places_attributes][index.to_s][:place_note])
      end
    end

    # Remove empty multi-value fields (person)
    if entry_params[:related_agents_attributes] != nil
      entry_params[:related_agents_attributes].each_with_index do |related_person, index|
        entry_params[:related_agents_attributes][index.to_s][:person_as_written] = remove_empty_array_fields2(entry_params[:related_agents_attributes][index.to_s][:person_as_written])
        entry_params[:related_agents_attributes][index.to_s][:person_role] = remove_empty_array_fields2(entry_params[:related_agents_attributes][index.to_s][:person_role])
        entry_params[:related_agents_attributes][index.to_s][:person_descriptor] = remove_empty_array_fields2(entry_params[:related_agents_attributes][index.to_s][:person_descriptor])
        entry_params[:related_agents_attributes][index.to_s][:person_descriptor_as_written] = remove_empty_array_fields2(entry_params[:related_agents_attributes][index.to_s][:person_descriptor_as_written])
        entry_params[:related_agents_attributes][index.to_s][:person_note] = remove_empty_array_fields2(entry_params[:related_agents_attributes][index.to_s][:person_note])
        entry_params[:related_agents_attributes][index.to_s][:person_related_place] = remove_empty_array_fields2(entry_params[:related_agents_attributes][index.to_s][:person_related_place])
        entry_params[:related_agents_attributes][index.to_s][:person_related_person] = remove_empty_array_fields2(entry_params[:related_agents_attributes][index.to_s][:person_related_person])
      end
    end
  end

  # Remove any empty date blocks, i.e. when all the fields are empty
  def remove_empty_date_blocks(entry_params)

    unless entry_params[:entry_dates_attributes].nil?

      entry_params[:entry_dates_attributes].each_with_index do |entry_date, index|

        single_date_exists = false

        # Check if a single date exists so that we can check if the whole date block should be deleted (see code later on)
        if entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes] != nil

          entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes].each_with_index do |single_date, index2|

            remove_single_date = true

            # Check all fields are empty
            # Ignore rdftype and id as we want to delete if ONLY these are present
            entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes][index2.to_s].each do |param|
              unless param[0] == 'id' or param[0] == 'rdftype'
                unless param[1].nil? or param[1] == '' or param[1] == []
                  remove_single_date = false
                  single_date_exists = true
                end
              end
            end
            if entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes][index2.to_s][:id] != nil
              if remove_single_date == true
                entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes][index2.to_s][:_destroy] = '1'
              end
            else
              if entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes][index2.to_s][:_destroy] == '1' or remove_single_date == true
                entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes][index2.to_s].delete(:rdftype)
                entry_params[:entry_dates_attributes][index.to_s][:single_dates_attributes][index2.to_s][:_destroy] = nil
              end
            end
          end
        end

        remove_date = true

        # Check all fields are empty
        # Ignore rdftype and id as we want to delete if ONLY these are present
        # Ignore single_dates_attributes as these are dealt with above
        entry_params[:entry_dates_attributes][index.to_s].each do |param|
          unless param[0] == 'id' or param[0] == 'rdftype' or param[0] == 'single_dates_attributes'
            unless param[1].nil? or param[1] == '' or param[1] == []
              remove_date = false
            end
          end
        end

        # Delete the whole date block if all of the fields are empty (but only do this for a saved entry, i.e. an id exists)
        if entry_params[:entry_dates_attributes][index.to_s][:id] != nil

          # Don't delete the date if there are associated single dates
          if remove_date == true and single_date_exists == false
            entry_params[:entry_dates_attributes][index.to_s].each do |param|
              unless param[0] == 'id' or param[0] == 'single_dates_attributes'
                entry_params[:entry_dates_attributes][index.to_s][param[0]] = ''
              end
            end
            entry_params[:entry_dates_attributes][index.to_s].delete(:rdftype)
            entry_params[:entry_dates_attributes][index.to_s][:_destroy] = '1'
          end

          # Else remove date when it has been added then deleted with the 'x' button (but has not been saved)
          # Note that '_destroy' = '1' was used to determine that the user had clicked on the 'x' button but we don't
          # want to send it with the form because it should only be used when an entry already exists in Fedora and we want
          # to delete it. It we didn't make it equal to 'nil' below I think the blank data is saved to Fedora!
        else
          if entry_params[:entry_dates_attributes][index.to_s][:_destroy] == '1' or (remove_date == true and remove_single_date == true)
            entry_params[:entry_dates_attributes][index.to_s].each do |param|
              entry_params[:entry_dates_attributes][index.to_s][param[0]] = ''
            end
            entry_params[:entry_dates_attributes][index.to_s].delete(:rdftype)
            entry_params[:entry_dates_attributes][index.to_s][:_destroy] = nil
          end
        end
      end
    end
  end


  # Remove empty place blocks, i.e. when all the fields are empty
  # Also remove block when user adds it and then clicks the 'x' button (without saving first)
  def remove_empty_place_blocks(entry_params)

    unless entry_params[:related_places_attributes].nil?

      entry_params[:related_places_attributes].each_with_index do |related_place, index|

        remove_place = true

        # Check all fields are empty
        # Ignore rdftype and id as we want to delete if ONLY these are present
        entry_params[:related_places_attributes][index.to_s].each do |param|
          unless param[0] == 'id' or param[0] == 'rdftype'
            unless param[1].nil? or param[1] == '' or param[1] == []
              remove_place = false
            end
          end
        end

        # Remove place if all fields are empty (but only do this for a saved entry, i.e. an id exists)
        if entry_params[:related_places_attributes][index.to_s][:id] != nil and remove_place == true

          entry_params[:related_places_attributes][index.to_s][:_destroy] = '1'

          # Else remove place when it has been added then deleted with the 'x' button (but has not been saved)
          # Note that '_destroy' = '1' was used to determine that the user had clicked on the 'x' button but we don't
          # want to send it with the form because it should only be used when an entry already exists in Fedora and we want
          # to delete it. It we didn't make it equal to 'nil' below I think the blank data is saved to Fedora!
        else
          if entry_params[:related_places_attributes][index.to_s][:_destroy] == '1' or remove_place == true
            entry_params[:related_places_attributes][index.to_s].each do |param|
              unless param[0] == 'id'
                entry_params[:related_places_attributes][index.to_s][param[0]] = ''
              end
            end
            entry_params[:related_places_attributes][index.to_s].delete(:rdftype)
            entry_params[:related_places_attributes][index.to_s][:_destroy] = nil
          end
        end
      end
    end
  end

  # Remove any empty person blocks, i.e. when all the fields are empty
  def remove_empty_person_blocks(entry_params)

    unless entry_params[:related_agents_attributes].nil?

      entry_params[:related_agents_attributes].each_with_index do |related_agent, index|

        remove_person = true

        # Check all fields are empty
        # Ignore rdftype, person/group and id as we want to delete if ONLY these are present
        entry_params[:related_agents_attributes][index.to_s].each do |param|
          unless param[0] == 'id' or param[0] == 'rdftype' or param[0] == 'person_group'
            unless param[1].nil? or param[1] == '' or param[1] == []
              remove_person = false
            end
          end
        end

        # Remove place if all fields are empty (but only do this for a saved entry, i.e. an id exists)
        if entry_params[:related_agents_attributes][index.to_s][:id] != nil and remove_person == true
          entry_params[:related_agents_attributes][index.to_s][:_destroy] = '1'

          # Else remove person when it has been added then deleted with the 'x' button (but has not been saved)
          # Note that '_destroy' = '1' was used to determine that the user had clicked on the 'x' button but we don't
          # want to send it with the form because it should only be used when an entry already exists in Fedora and we want
          # to delete it. It we didn't make it equal to 'nil' below I think the blank data is saved to Fedora!
        else
          if entry_params[:related_agents_attributes][index.to_s][:_destroy] == '1' or remove_person == true
            entry_params[:related_agents_attributes][index.to_s].each do |param|
              unless param[0] == 'id'
                entry_params[:related_agents_attributes][index.to_s][param[0]] = ''
              end
            end
            entry_params[:related_agents_attributes][index.to_s].delete(:rdftype)
            entry_params[:related_agents_attributes][index.to_s][:_destroy] = nil
          end
        end
      end
    end
  end

  # Note that an error occurred when the form was submitted with no multi-value elements
  # Therefore, instead of just removing elements when the user clicks on the 'x' icon, the elements are hidden and the value set to ''
  # The code below will then remove the empty fields before they are saved to Fedora
  # Note also that a check is made on the size of the array because an empty array is passed when the 'edit' button is clicked,
  # (i.e. if there are no elements)  - we don't want to check if the elements are blank if none exist otherwise an error will occur
  def remove_empty_array_fields2(element)
    if element != nil && element.size > 0
      return element.select { |element| element.present? }
    else
      return element
    end
  end

  # Remove place multi-value fields (i.e. arrays) such as 'Feature Code'
  # This is required because empty array fields are submitted as [''] and an empty field will be added to Fedora
  def remove_place_popup_empty_fields(place_params)
    place_params[:feature_code] = remove_empty_array_fields2(place_params[:feature_code])
    place_params[:same_as] = remove_empty_array_fields2(place_params[:same_as])
    place_params[:related_authority] = remove_empty_array_fields2(place_params[:related_authority])
    place_params[:altlabel] = remove_empty_array_fields2(place_params[:altlabel])
  end

  # Remove person multi-value fields (i.e. arrays) such as 'Same As'
  # This is required because empty array fields are submitted as [''] and an empty field will be added to Fedora
  def remove_person_popup_empty_fields(person_params)
    person_params[:same_as] = remove_empty_array_fields2(person_params[:same_as])
    person_params[:related_authority] = remove_empty_array_fields2(person_params[:related_authority])
    person_params[:altlabel] = remove_empty_array_fields2(person_params[:altlabel])
    person_params[:note] = remove_empty_array_fields2(person_params[:note])
  end

  # Remove group multi-value fields (i.e. arrays) such as 'Same As'
  # This is required because empty array fields are submitted as [''] and an empty field will be added to Fedora
  def remove_group_popup_empty_fields(group_params)
    group_params[:same_as] = remove_empty_array_fields2(group_params[:same_as])
    group_params[:related_authority] = remove_empty_array_fields2(group_params[:related_authority])
    group_params[:altlabel] = remove_empty_array_fields2(group_params[:altlabel])
    group_params[:note] = remove_empty_array_fields2(group_params[:note])
  end

  def remove_concept_popup_empty_fields(concept_params)
    concept_params[:altlabel] = remove_empty_array_fields2(concept_params[:altlabel])
  end
end