class CreateNutrients < ActiveRecord::Migration[8.1]
  def change
    create_table :nutrients do |t|
      t.string :code, null: false
      t.string :short_name_en
      t.string :med_name_en
      t.string :long_name_en
      t.string :med_name_ukr
      t.string :long_name_ukr
      t.string :group
      t.string :unit
      t.timestamps
    end

    add_index :nutrients, :code, unique: true
  end
end
