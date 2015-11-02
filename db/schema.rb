# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system

ActiveRecord::Schema.define(version: 20151007160634) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "db_date_certainties", force: :cascade do |t|
    t.string  "name"
    t.integer "db_single_date_id"
  end

  add_index "db_date_certainties", ["db_single_date_id"], name: "index_db_date_certainties_on_db_single_date_id"

  create_table "db_editorial_notes", force: :cascade do |t|
    t.string  "name"
    t.integer "db_entry_id"
  end

  add_index "db_editorial_notes", ["db_entry_id"], name: "index_db_editorial_notes_on_db_entry_id"

  create_table "db_entries", force: :cascade do |t|
    t.string "entry_no"
    t.string "entry_type"
    t.string "summary"
    t.string "continues_on"
    t.string "entry_id"
    t.string "rdftype"
  end

  create_table "db_entry_dates", force: :cascade do |t|
    t.string  "date_role"
    t.string  "date_note"
    t.integer "db_entry_id"
  end

  add_index "db_entry_dates", ["db_entry_id"], name: "index_db_entry_dates_on_db_entry_id"

  create_table "db_is_referenced_bies", force: :cascade do |t|
    t.string  "name"
    t.integer "db_entry_id"
  end

  add_index "db_is_referenced_bies", ["db_entry_id"], name: "index_db_is_referenced_bies_on_db_entry_id"

  create_table "db_languages", force: :cascade do |t|
    t.string  "name"
    t.integer "db_entry_id"
  end

  add_index "db_languages", ["db_entry_id"], name: "index_db_languages_on_db_entry_id"

  create_table "db_marginalia", force: :cascade do |t|
    t.string  "name"
    t.integer "db_entry_id"
  end

  add_index "db_marginalia", ["db_entry_id"], name: "index_db_marginalia_on_db_entry_id"

  create_table "db_notes", force: :cascade do |t|
    t.string  "name"
    t.integer "db_entry_id"
  end

  add_index "db_notes", ["db_entry_id"], name: "index_db_notes_on_db_entry_id"

  create_table "db_person_as_writtens", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_person_group_id"
  end

  add_index "db_person_as_writtens", ["db_related_person_group_id"], name: "index_db_person_as_writtens_on_db_related_person_group_id"

  create_table "db_person_descriptor_as_writtens", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_person_group_id"
  end

  add_index "db_person_descriptor_as_writtens", ["db_related_person_group_id"], name: "index_db_per_desc_as_writtens_on_db_related_person_group_id"

  create_table "db_person_descriptors", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_person_group_id"
  end

  add_index "db_person_descriptors", ["db_related_person_group_id"], name: "index_db_person_descriptors_on_db_related_person_group_id"

  create_table "db_person_notes", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_person_group_id"
  end

  add_index "db_person_notes", ["db_related_person_group_id"], name: "index_db_person_notes_on_db_related_person_group_id"

  create_table "db_person_related_places", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_person_group_id"
  end

  add_index "db_person_related_places", ["db_related_person_group_id"], name: "index_db_person_related_places_on_db_related_person_group_id"

  create_table "db_person_roles", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_person_group_id"
  end

  add_index "db_person_roles", ["db_related_person_group_id"], name: "index_db_person_roles_on_db_related_person_group_id"

  create_table "db_place_as_writtens", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_place_id"
  end

  add_index "db_place_as_writtens", ["db_related_place_id"], name: "index_db_place_as_writtens_on_db_related_place_id"

  create_table "db_place_notes", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_place_id"
  end

  add_index "db_place_notes", ["db_related_place_id"], name: "index_db_place_notes_on_db_related_place_id"

  create_table "db_place_roles", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_place_id"
  end

  add_index "db_place_roles", ["db_related_place_id"], name: "index_db_place_roles_on_db_related_place_id"

  create_table "db_place_types", force: :cascade do |t|
    t.string  "name"
    t.integer "db_related_place_id"
  end

  add_index "db_place_types", ["db_related_place_id"], name: "index_db_place_types_on_db_related_place_id"

  create_table "db_related_person_groups", force: :cascade do |t|
    t.string  "person_same_as"
    t.string  "person_gender"
    t.integer "db_entry_id"
  end

  add_index "db_related_person_groups", ["db_entry_id"], name: "index_db_related_person_groups_on_db_entry_id"

  create_table "db_related_places", force: :cascade do |t|
    t.string  "place_same_as"
    t.integer "db_entry_id"
  end

  add_index "db_related_places", ["db_entry_id"], name: "index_db_related_places_on_db_entry_id"

  create_table "db_section_types", force: :cascade do |t|
    t.string  "name"
    t.integer "db_entry_id"
  end

  add_index "db_section_types", ["db_entry_id"], name: "index_db_section_types_on_db_entry_id"

  create_table "db_single_dates", force: :cascade do |t|
    t.string  "date"
    t.string  "date_type"
    t.integer "db_entry_date_id"
  end

  add_index "db_single_dates", ["db_entry_date_id"], name: "index_db_single_dates_on_db_entry_date_id"

  create_table "db_subjects", force: :cascade do |t|
    t.string  "name"
    t.integer "db_entry_id"
  end

  add_index "db_subjects", ["db_entry_id"], name: "index_db_subjects_on_db_entry_id"

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
