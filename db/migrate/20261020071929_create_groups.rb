class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.string :source_code
      t.string :code
      t.text :name_en
      t.text :name_ukr

      t.timestamps
    end
  end
end
