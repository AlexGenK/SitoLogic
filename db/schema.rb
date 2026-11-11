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

ActiveRecord::Schema[8.1].define(version: 2026_11_11_090100) do
  create_table "food_nutrients", force: :cascade do |t|
    t.integer "food_id", null: false
    t.integer "nutrient_id", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_id", "nutrient_id"], name: "index_food_nutrients_on_food_id_and_nutrient_id", unique: true
    t.index ["nutrient_id"], name: "index_food_nutrients_on_nutrient_id"
  end

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
    t.index ["source_code"], name: "index_foods_on_source_code"
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

  create_table "menu_items", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.integer "day", null: false
    t.integer "meal", null: false
    t.integer "position", null: false
    t.integer "variant", null: false
    t.integer "food_id", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_id"], name: "index_menu_items_on_food_id"
    t.index ["menu_id", "day", "meal", "position", "variant"], name: "idx_on_menu_id_day_meal_position_variant_53befe582e", unique: true
  end

  create_table "menus", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "days_count", null: false
    t.integer "meals_per_day", null: false
    t.integer "items_per_meal", null: false
    t.integer "variants_per_item", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_menus_on_code", unique: true
  end

  create_table "nutrients", force: :cascade do |t|
    t.string "code", null: false
    t.string "short_name_en"
    t.string "med_name_en"
    t.string "long_name_en"
    t.string "med_name_ukr"
    t.string "long_name_ukr"
    t.string "group"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_nutrients_on_code", unique: true
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

  add_foreign_key "food_nutrients", "foods"
  add_foreign_key "food_nutrients", "nutrients"
  add_foreign_key "menu_items", "foods"
  add_foreign_key "menu_items", "menus"
end
