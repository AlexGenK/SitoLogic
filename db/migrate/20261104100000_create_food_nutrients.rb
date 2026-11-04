class CreateFoodNutrients < ActiveRecord::Migration[8.1]
  def change
    create_table :food_nutrients do |t|
      t.references :food, null: false, foreign_key: true, index: false
      t.references :nutrient, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.timestamps
    end

    add_index :food_nutrients, [ :food_id, :nutrient_id ], unique: true
  end
end
