class CreateTables < ActiveRecord::Migration

  def change

    create_table :db_entries do |t|
      t.string :entry_no
      t.string :entry_type
      t.string :summary
      t.string :continues_on
      t.string :entry_id
    end

    create_table :db_section_types do |t|
      t.string :name
      t.references :db_entry, index: true
    end

    add_foreign_key :db_section_types, :db_entries

    create_table :db_marginalia do |t|
      t.string :name
      t.references :db_entry, index: true
    end

    add_foreign_key :db_marginalia, :db_entries

    create_table :db_languages do |t|
      t.string :name
      t.references :db_entry, index: true
    end

    add_foreign_key :db_languages, :db_entries

    create_table :db_subjects do |t|
      t.string :name
      t.references :db_entry, index: true
    end

    add_foreign_key :db_subjects, :db_entries

    create_table :db_notes do |t|
      t.string :name
      t.references :db_entry, index: true
    end

    add_foreign_key :db_notes, :db_entries

    create_table :db_editorial_notes do |t|
      t.string :name
      t.references :db_entry, index: true
    end

    add_foreign_key :db_editorial_notes, :db_entries

    create_table :db_is_referenced_bies do |t|
      t.string :name
      t.references :db_entry, index: true
    end

    add_foreign_key :db_is_referenced_bies, :db_entries

    create_table :db_entry_dates do |t|
      t.string :date_role
      t.string :date_note
      t.references :db_entry, index: true
    end

    add_foreign_key :db_entry_dates, :db_entries

    create_table :db_single_dates do |t|
      t.string :date
      t.string :date_type
      t.references :db_entry_date, index: true
    end

    add_foreign_key :db_single_dates, :db_entry_dates

    create_table :db_date_certainties do |t|
      t.string :name
      t.references :db_single_date, index: true
    end

    add_foreign_key :db_date_certainties, :db_single_dates

    create_table :db_related_places do |t|
      t.string :place_same_as
      t.references :db_entry, index: true
    end

    add_foreign_key :db_related_places, :db_entries

    create_table :db_place_as_writtens do |t|
      t.string :name
      t.references :db_related_place, index: true
    end

    add_foreign_key :db_place_as_writtens, :db_related_places

    create_table :db_place_types do |t|
      t.string :name
      t.references :db_related_place, index: true
    end

    add_foreign_key :db_place_types, :db_related_places

    create_table :db_place_roles do |t|
      t.string :name
      t.references :db_related_place, index: true
    end

    add_foreign_key :db_place_roles, :db_related_places

    create_table :db_place_notes do |t|
      t.string :name
      t.references :db_related_place, index: true
    end

    add_foreign_key :db_place_notes, :db_related_places

    create_table :db_related_person_groups do |t|
      t.string :person_same_as
      t.string :person_gender
      t.references :db_entry, index: true
    end

    add_foreign_key :db_related_person_groups, :db_entries

    create_table :db_person_as_writtens do |t|
      t.string :name
      t.references :db_related_person_group, index: true
    end

    add_foreign_key :db_person_as_writtens, :db_related_person_groups

    create_table :db_person_roles do |t|
      t.string :name
      t.references :db_related_person_group, index: true
    end

    add_foreign_key :db_person_roles, :db_related_person_groups

    create_table :db_person_descriptors do |t|
      t.string :name
      t.references :db_related_person_group, index: true
    end

    add_foreign_key :db_person_descriptors, :db_related_person_groups

    create_table :db_person_descriptor_as_writtens do |t|
      t.string :name
      t.references :db_related_person_group, index: false
    end

    add_foreign_key :db_person_descriptor_as_writtens, :db_related_person_groups

    # Note that 'index' = false in the above table because the index created has a name which is too long (> 62 characters) - therefore, I'm creating my own index name...
    add_index "db_person_descriptor_as_writtens", ["db_related_person_group_id"], name: "index_db_per_desc_as_writtens_on_db_related_person_group_id"

    create_table :db_person_notes do |t|
      t.string :name
      t.references :db_related_person_group, index: true
    end

    add_foreign_key :db_person_notes, :db_related_person_groups

    create_table :db_person_related_places do |t|
      t.string :name
      t.references :db_related_person_group, index: true
    end

    add_foreign_key :db_person_related_places, :db_related_person_groups
  end
end
