class DropTables < ActiveRecord::Migration
  def change
    drop_table :db_entries
    drop_table :db_section_types
    drop_table :db_marginalia
    drop_table :db_languages
    drop_table :db_subjects
    drop_table :db_notes
    drop_table :db_editorial_notes
    drop_table :db_is_referenced_bies
    drop_table :db_entry_dates
    drop_table :db_single_dates
    drop_table :db_date_certainties
    drop_table :db_related_places
    drop_table :db_place_as_writtens
    drop_table :db_place_types
    drop_table :db_place_roles
    drop_table :db_place_notes
    drop_table :db_related_agents
    drop_table :db_person_as_writtens
    drop_table :db_person_roles
    drop_table :db_person_descriptors
    drop_table :db_person_descriptor_as_writtens
    drop_table :db_person_notes
    drop_table :db_person_related_places
  end
end

