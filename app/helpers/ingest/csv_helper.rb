require "smarter_csv"

module Ingest
  module CsvHelper
    REGISTER_CSV_HEADER = [
      "register_no", "folio_no", "folio_side",
      # Entry
      "entry_no", "entry_type_1", "entry_type_2", "entry_type_3", "section_type",
      # Continues/End
      "continue_folio_no", "continue_folio_side",
      # Entry Summary
      "summary", "marginalia", "language_1", "language_2",
      # Subjects
      "subject_1", "subject_2", "subject_3", "subject_4", "note", "referenced_by",
      # Entry date 1
      "date_1", "certainty_1", "type_1", "date_role_1", "note_date_1",
      # Entry date 2
      "date_2", "certainty_2", "type_2", "date_role2", "note_date_2",
      # Place-Name
      "place_as_written", "place_name_authority", "place_role", "place_type", "note_place",
      # Group 1
      "group_as_written_1", "group_or_person_1", "group_name_authority_1", "group_gender_1",
      "group_person_role_1", "group_Descriptor_1", "group_Note_1",
      # Group 2
      "group_AsWritten_2", "group_OrPerson_2", "group_NameAuthority_2", "group_Gender_2",
      "group_person_role_2", "group_Descriptor_2", "group_Note_2",
      # Person 1
      "person_as_written_1", "person_or_group_1", "people_name_authority_1", "person_gender_1", "person_role_1", "person_descriptor_1", "person_note_1",
      # Person 2
      "person_as_written_2", "person_or_group_2", "people_name_authority_2", "person_gender_2", "person_role_2", "person_descriptor_2", "person_note_2",
      # Person 3
      "person_as_written_3", "person_or_group_3", "people_name_authority_3", "person_gender_3", "person_role_3", "person_descriptor_3", "person_note_3",
    ]

    # pars data from Borthwick CSV file
    def self.parse_borthwick_spreadsheet(filename)
      entry_rows = []
      options = { user_provided_headers: Ingest::CsvHelper::REGISTER_CSV_HEADER, headers_in_file: false }
      entries = SmarterCSV.process(filename, options)
      entries.each do |entry|
        entry_row = Ingest::BorthwickEntry.new(entry)
        entry_rows << entry_row
      end

      entry_rows
    end
  end
end
