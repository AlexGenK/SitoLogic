# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_28_090000) do
  create_table "foods", force: :cascade do |t|
    t.string "code"
    t.string "name_en"
    t.text "description_en"
    t.text "comment_en"
    t.string "name_ukr"
    t.text "description_ukr"
    t.text "comment_ukr"
    t.string "source_code"
    t.string "group_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group_type"
    t.index ["group_type", "group_code"], name: "index_foods_on_group_type_and_group_code"
  end

  create_table "groups", force: :cascade do |t|
    t.string "group_type"
    t.string "code"
    t.text "name_en"
    t.text "name_ukr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_type", "code"], name: "index_groups_on_group_type_and_code", unique: true
  end

  create_table "sources", force: :cascade do |t|
    t.string "code"
    t.text "name_en"
    t.text "name_ukr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group_type"
    t.index ["group_type"], name: "index_sources_on_group_type"
  end
end
