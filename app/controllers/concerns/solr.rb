module Solr

  def get_solr_data(db_entry)

    SolrQuery.new.solr_query('id:' + db_entry.entry_id, 'entry_no_tesim, entry_type_tesim, section_type_tesim, continues_on_tesim, summary_tesim, marginalia_tesim, language_tesim, subject_tesim, note_tesim, editorial_note_tesim, is_referenced_by_tesim', 1)['response']['docs'].map do |result|

      if result['entry_no_tesim'] != nil

        db_entry.id = db_entry.entry_id.gsub(/test:/, '').to_i

        db_entry.entry_no = result['entry_no_tesim'].join()

        entry_type_list = result['entry_type_tesim'];

        if entry_type_list != nil
          entry_type_list.each do |tt|
            db_entry_type = DbEntryType.new
            db_entry_type.name = tt
            db_entry.db_entry_types << db_entry_type
          end
        end

        section_type_list = result['section_type_tesim'];

        if section_type_list != nil
          section_type_list.each do |tt|
            db_section_type = DbSectionType.new
            db_section_type.name = tt
            db_entry.db_section_types << db_section_type
          end
        end

        if result['continues_on_tesim'] != nil
          db_entry.continues_on = result['continues_on_tesim'].join()
        end

        summary = result['summary_tesim']

        if summary != nil
          db_entry.summary = summary.join()
        end

        marginalium_list = result['marginalia_tesim'];

        if marginalium_list != nil
          marginalium_list.each do |tt|
            db_marginalium = DbMarginalium.new
            db_marginalium.name = tt
            db_entry.db_marginalia << db_marginalium
          end
        end

        language_list = result['language_tesim'];

        if language_list != nil
          language_list.each do |tt|
            db_language = DbLanguage.new
            db_language.name = tt
            db_entry.db_languages << db_language
          end
        end

        subject_list = result['subject_tesim'];

        if subject_list != nil
          subject_list.each do |tt|
            db_subject = DbSubject.new
            db_subject.name = tt
            db_entry.db_subjects << db_subject
          end
        end

        note_list = result['note_tesim'];

        if note_list != nil
          note_list.each do |tt|
            db_note = DbNote.new
            db_note.name = tt
            db_entry.db_notes << db_note
          end
        end

        editorial_note_list = result['editorial_note_tesim'];

        if editorial_note_list != nil
          editorial_note_list.each do |tt|
            db_editorial_note = DbEditorialNote.new
            db_editorial_note.name = tt
            db_entry.db_editorial_notes << db_editorial_note
          end
        end

        is_referenced_by_list = result['is_referenced_by_tesim'];

        if is_referenced_by_list != nil
          is_referenced_by_list.each do |tt|
            db_is_referenced_by = DbIsReferencedBy.new
            db_is_referenced_by.name = tt
            db_entry.db_is_referenced_bys << db_is_referenced_by
          end
        end

        SolrQuery.new.solr_query('has_model_ssim:EntryDate AND entryDateFor_ssim:' + db_entry.entry_id, 'id, date_role_tesim, date_note_tesim', 100)['response']['docs'].map do |result|

          date_id = result['id'];

          if date_id != nil

            db_entry_date = DbEntryDate.new

            db_entry_date.id = date_id.gsub(/test:/, '').to_i

            SolrQuery.new.solr_query('has_model_ssim:SingleDate AND dateFor_ssim:' + date_id, 'id, date_tesim, date_type_tesim, date_certainty_tesim', 100)['response']['docs'].map do |result2|

              single_date_id = result2['id'];

              if single_date_id != nil

                db_single_date = DbSingleDate.new

                db_single_date.id = single_date_id.gsub(/test:/, '').to_i

                date_certainty_list = result2['date_certainty_tesim'];

                if date_certainty_list != nil
                  date_certainty_list.each do |tt|
                    db_date_certainty = DbDateCertainty.new
                    db_date_certainty.name = tt
                    db_single_date.db_date_certainties << db_date_certainty
                  end
                end

                date = result2['date_tesim']

                if date != nil
                  db_single_date.date = date.join()
                end

                date_type = result2['date_type_tesim']

                if date_type != nil
                  db_single_date.date_type = date_type.join()
                end

                db_entry_date.db_single_dates << db_single_date
              end
            end

            date_role = result['date_role_tesim']

            if date_role != nil
              db_entry_date.date_role = date_role.join()
            end

            date_note = result['date_note_tesim']

            if date_note != nil
              db_entry_date.date_note = date_note.join()
            end

            db_entry.db_entry_dates << db_entry_date
          end
        end

        SolrQuery.new.solr_query('has_model_ssim:RelatedPlace AND relatedPlaceFor_ssim:"' + db_entry.entry_id + '"', 'id, place_same_as_tesim, place_as_written_tesim, place_role_tesim, place_type_tesim, place_note_tesim', 100)['response']['docs'].map do |result|

          related_place_id = result['id'];

          if related_place_id != nil

            db_related_place = DbRelatedPlace.new

            db_related_place.id = related_place_id.gsub(/test:/, '').to_i

            place_same_as = result['place_same_as_tesim']

            if place_same_as != nil
              db_related_place.place_same_as = place_same_as.join()
            end

            place_as_written_list = result['place_as_written_tesim'];

            if place_as_written_list != nil
              place_as_written_list.each do |tt|
                db_place_as_written = DbPlaceAsWritten.new
                db_place_as_written.name = tt
                db_related_place.db_place_as_writtens << db_place_as_written
              end
            end

            place_role_list = result['place_role_tesim'];

            if place_role_list != nil
              place_role_list.each do |tt|
                db_place_role = DbPlaceRole.new
                db_place_role.name = tt
                db_related_place.db_place_roles << db_place_role
              end
            end

            place_type_list = result['place_type_tesim'];

            if place_type_list != nil
              place_type_list.each do |tt|
                db_place_type = DbPlaceType.new
                db_place_type.name = tt
                db_related_place.db_place_types << db_place_type
              end
            end

            place_note_list = result['place_note_tesim'];

            if place_note_list != nil
              place_note_list.each do |tt|
                db_place_note = DbPlaceNote.new
                db_place_note.name = tt
                db_related_place.db_place_notes << db_place_note
              end
            end

            db_entry.db_related_places << db_related_place
          end
        end

        SolrQuery.new.solr_query('has_model_ssim:RelatedPersonGroup AND relatedAgentFor_ssim:"' + db_entry.entry_id + '"', 'id, person_same_as_tesim, person_gender_tesim, person_as_written_tesim, person_role_tesim, person_descriptor_tesim, person_descriptor_as_written_tesim, person_note_tesim, person_related_place_tesim, person_related_person_tesim', 100)['response']['docs'].map do |result|

          related_person_group_id = result['id'];

          if related_person_group_id != nil

            db_related_person_group = DbRelatedPersonGroup.new

            db_related_person_group.id = related_person_group_id.gsub(/test:/, '').to_i

            person_same_as = result['person_same_as_tesim']

            if person_same_as != nil
              db_related_person_group.person_same_as = person_same_as.join()
            end

            person_gender = result['person_gender_tesim']

            if person_gender != nil
              db_related_person_group.person_gender = person_gender.join()
            end

            person_as_written_list = result['person_as_written_tesim'];

            if person_as_written_list != nil
              person_as_written_list.each do |tt|
                db_person_as_written = DbPersonAsWritten.new
                db_person_as_written.name = tt
                db_related_person_group.db_person_as_writtens << db_person_as_written
              end
            end

            person_role_list = result['person_role_tesim'];

            if person_role_list != nil
              person_role_list.each do |tt|
                db_person_role = DbPersonRole.new
                db_person_role.name = tt
                db_related_person_group.db_person_roles << db_person_role
              end
            end

            person_descriptor_list = result['person_descriptor_tesim'];

            if person_descriptor_list != nil
              person_descriptor_list.each do |tt|
                db_person_descriptor = DbPersonDescriptor.new
                db_person_descriptor.name = tt
                db_related_person_group.db_person_descriptors << db_person_descriptor
              end
            end

            person_descriptor_as_written_list = result['person_descriptor_as_written_tesim'];

            if person_descriptor_as_written_list != nil
              person_descriptor_as_written_list.each do |tt|
                db_person_descriptor_as_written = DbPersonDescriptorAsWritten.new
                db_person_descriptor_as_written.name = tt
                db_related_person_group.db_person_descriptor_as_writtens << db_person_descriptor_as_written
              end
            end

            person_note_list = result['person_note_tesim'];

            if person_note_list != nil
              person_note_list.each do |tt|
                db_person_note = DbPersonNote.new
                db_person_note.name = tt
                db_related_person_group.db_person_notes << db_person_note
              end
            end

            person_related_place_list = result['person_related_place_tesim'];

            if person_related_place_list != nil
              person_related_place_list.each do |tt|
                db_person_related_place = DbPersonRelatedPlace.new
                db_person_related_place.name = tt
                db_related_person_group.db_person_related_places << db_person_related_place
              end
            end

            person_related_person_list = result['person_related_person_tesim'];

            if person_related_person_list != nil
              person_related_person_list.each do |tt|
                db_person_related_person = DbPersonRelatedPerson.new
                db_person_related_person.name = tt
                db_related_person_group.db_person_related_people << db_person_related_person
              end
            end

            db_entry.db_related_person_groups << db_related_person_group
          end
        end
      end
    end
  end

end