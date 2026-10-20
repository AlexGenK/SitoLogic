class CreateSources < ActiveRecord::Migration[8.1]
  def change
    create_table :sources do |t|
      t.string :code
      t.text :name_en
      t.text :name_ukr

      t.timestamps
    end
  end
end
