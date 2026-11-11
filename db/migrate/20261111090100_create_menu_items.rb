class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.references :menu, null: false, foreign_key: true, index: false
      t.integer :day, null: false
      t.integer :meal, null: false
      t.integer :position, null: false
      t.integer :variant, null: false
      t.references :food, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.timestamps
    end

    add_index :menu_items, [ :menu_id, :day, :meal, :position, :variant ], unique: true
  end
end
