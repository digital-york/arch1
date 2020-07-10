module Ingest
  class BorthwickEntry
    EntryDate = Struct.new(:date, :certanity, :type, :role, :note)
    PlaceName = Struct.new(:as_written, :name_authority, :role, :type, :note)
    Group = Struct.new(:as_written, :group_or_person, :name_authority, :gender, :role, :descriptor, :note)
    Person = Struct.new(:as_written, :person_or_group, :name_authority, :gender, :role, :descriptor, :note)
    attr_accessor :register_no,
                  :folio_no,
                  :folio_side,
                  :entry_no,
                  :entry_types,
                  :continue_folio_no,
                  :continue_folio_side,
                  :summary,
                  :subjects,
                  :note,
                  :referenced_by,
                  :entry_dates,
                  :place_name,
                  :groups,
                  :persons

    def initialize(data)
      @register_no = data[:register_no]
      @folio_no = data[:folio_no]
      @folio_side = data[:folio_side]
      @entry_no = data[:entry_no]

      @entry_types = []
      @entry_types << data[:entry_type_1] unless data[:entry_type_1].nil?
      @entry_types << data[:entry_type_2] unless data[:entry_type_2].nil?
      @entry_types << data[:entry_type_3] unless data[:entry_type_3].nil?

      @section_type = data[:section_type] unless data[:section_type].nil?
      @continue_folio_no = data[:continue_folio_no] unless data[:continue_folio_no].nil?
      @continue_folio_side = data[:continue_folio_side] unless data[:continue_folio_side].nil?
      @summary = data[:summary] unless data[:summary].nil?

      @subjects = []
      @subjects << data[:subject_1] unless data[:subject_1].nil?
      @subjects << data[:subject_2] unless data[:subject_2].nil?
      @subjects << data[:subject_3] unless data[:subject_3].nil?
      @subjects << data[:subject_4] unless data[:subject_4].nil?

      @note = data[:note] unless data[:note].nil?
      @referenced_by = data[:referenced_by] unless data[:referenced_by].nil?

      @entry_dates = []
      unless data[:date_1].nil?
        date = EntryDate.new
        date.date = data[:date_1]
        date.certanity = data[:certainty_1]
        date.type = data[:type_1]
        date.role = data[:date_role_1]
        date.note = data[:note_date_1]
        @entry_dates << date
      end
      unless data[:date_2].nil?
        date = EntryDate.new
        date.date = data[:date_2]
        date.certanity = data[:certainty_2]
        date.type = data[:type_2]
        date.role = data[:date_role_2]
        date.note = data[:note_date_2]
        @entry_dates << date
      end

      @place_name = PlaceName.new
      @place_name.as_written = data[:place_as_written]
      @place_name.name_authority = data[:place_name_authority]
      @place_name.role = data[:place_role]
      @place_name.type = data[:place_type]
      @place_name.note = data[:note_place]

      @groups = []
      unless data[:group_as_written_1].nil?
        group = Group.new
        group.as_written = data[:group_as_written_1]
        group.group_or_person = data[:group_or_person_1]
        group.name_authority = data[:group_name_authority_1]
        group.gender = data[:group_gender_1]
        group.role = data[:group_person_role_1]
        group.descriptor = data[:group_descriptor_1]
        group.note = data[:group_note_1]
        @groups << group
      end

      unless data[:group_as_written_2].nil?
        group = Group.new
        group.as_written = data[:group_as_written_2]
        group.group_or_person = data[:group_or_person_2]
        group.name_authority = data[:group_name_authority_2]
        group.gender = data[:group_gender_2]
        group.role = data[:group_person_role_2]
        group.descriptor = data[:group_descriptor_2]
        group.note = data[:group_note_2]
        @groups << group
      end

      @persons = []
      unless data[:person_as_written_1].nil?
        person = Person.new
        person.as_written = data[:person_as_written_1]
        person.person_or_group = data[:person_or_group_1]
        person.name_authority = data[:people_name_authority_1]
        person.gender = data[:person_gender_1]
        person.role = data[:person_role_1]
        person.descriptor = data[:person_descriptor_1]
        person.note = data[:person_note_1]
        persons << person
      end

      unless data[:person_as_written_2].nil?
        person = Person.new
        person.as_written = data[:person_as_written_2]
        person.person_or_group = data[:person_or_group_2]
        person.name_authority = data[:people_name_authority_2]
        person.gender = data[:person_gender_2]
        person.role = data[:person_role_2]
        person.descriptor = data[:person_descriptor_2]
        person.note = data[:person_note_2]
        persons << person
      end

      unless data[:person_as_written_3].nil?
        person = Person.new
        person.as_written = data[:person_as_written_3]
        person.person_or_group = data[:person_or_group_3]
        person.name_authority = data[:people_name_authority_3]
        person.gender = data[:person_gender_3]
        person.role = data[:person_role_3]
        person.descriptor = data[:person_descriptor_3]
        person.note = data[:person_note_3]
        persons << person
      end
    end

    def to_s
      @register_no + " / " + @folio_no.to_s + " / " + @folio_side + " / " + @entry_no.to_s +
        " / " + @entry_types.to_s
    end
  end
end
