module Ingest
    # This class defines all fields loaded from TNA spreadsheet
    class TnaEntryRow
        attr_reader :repository,
                    :volume,
                    :page_number,
                    :sequence,
                    :entry_type,
                    :summary,
                    :language,
                    :subjects,
                    :note,
                    :editorial_note,
                    :publication_volume,
                    :page_number,
                    :publication_sequence,
                    :entry_date1_note,
                    :entry_date2_date,
                    :entry_date2_certainty,
                    :entry_date2_type,
                    :entry_date2_date_role,
                    :entry_date2_note,
                    :place_as,        # place as written, string
                    :place_name,      # place name, which will be used to search place authority id
                    :place_role,
                    :place_type,
                    :place_note,
                    :image_id,
                    :group1_as_written,
                    :group1_person_or,
                    :group1_group,
                    :group1_gender,
                    :group1_person_role,
                    :group1_descriptor,
                    :group1_note,
                    :group2_as_written,
                    :group2_person_or,
                    :group2_group,
                    :group2_gender,
                    :group2_person_role,
                    :group2_descriptor,
                    :group2_note,
                    :person1_as_written,
                    :person1_person_group,
                    :person1_people_name,
                    :person1_gender,
                    :person1_person_role,
                    :person1_descriptor,
                    :person1_note,
                    :person2_as_written,
                    :person2_person_group,
                    :person2_people_name,
                    :person2_gender,
                    :person2_person_role,
                    :person2_descriptor,
                    :person2_note,
                    :person3_as_written,
                    :person3_person_group,
                    :person3_people_name,
                    :person3_gender,
                    :person3_person_role,
                    :person3_descriptor,
                    :person3_note

        attr_writer :register,
                    :folio_no,
                    :folio_side,
                    :entry_no,
                    :entry_type1,
                    :entry_type2,
                    :entry_type3,
                    :section_type,
                    :continues_folio_no,
                    :continues_folio_side,
                    :continues_image_id,
                    :summary,
                    :marginalia,
                    :language1,
                    :language2,
                    :subject1,
                    :subject2,
                    :subject3,
                    :subject4,
                    :note,
                    :referenced_by,
                    :entry_date1_date,
                    :entry_date1_certainty,
                    :entry_date1_type,
                    :entry_date1_date_role,
                    :entry_date1_note,
                    :entry_date2_date,
                    :entry_date2_certainty,
                    :entry_date2_type,
                    :entry_date2_date_role,
                    :entry_date2_note,
                    :place_as,
                    :place_name,
                    :place_role,
                    :place_type,
                    :place_note,
                    :image_id,
                    :group1_as_written,
                    :group1_person_or,
                    :group1_group,
                    :group1_gender,
                    :group1_person_role,
                    :group1_descriptor,
                    :group1_note,
                    :group2_as_written,
                    :group2_person_or,
                    :group2_group,
                    :group2_gender,
                    :group2_person_role,
                    :group2_descriptor,
                    :group2_note,
                    :person1_as_written,
                    :person1_person_group,
                    :person1_people_name,
                    :person1_gender,
                    :person1_person_role,
                    :person1_descriptor,
                    :person1_note,
                    :person2_as_written,
                    :person2_person_group,
                    :person2_people_name,
                    :person2_gender,
                    :person2_person_role,
                    :person2_descriptor,
                    :person2_note,
                    :person3_as_written,
                    :person3_person_group,
                    :person3_people_name,
                    :person3_gender,
                    :person3_person_role,
                    :person3_descriptor,
                    :person3_note

        def to_s
            if image_id.blank?
                register + ' / ' + folio_no.to_s + ' / ' +folio_side + ' / ' + entry_no.to_s
            else
                register + ' / ' + folio_no.to_s + ' / ' +folio_side + ' / ' + entry_no.to_s + ' / ' + image_id
            end
        end
    end
end