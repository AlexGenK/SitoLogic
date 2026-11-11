class CreateMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :menus do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.integer :days_count, null: false
      t.integer :meals_per_day, null: false
      t.integer :items_per_meal, null: false
      t.integer :variants_per_item, null: false
      t.timestamps
    end

    add_index :menus, :code, unique: true
  end
end
