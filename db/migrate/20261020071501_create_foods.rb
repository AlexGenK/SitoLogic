class CreateFoods < ActiveRecord::Migration[8.1]
  def change
    create_table :foods do |t|
      t.string :code
      t.string :name_en
      t.text :description_en
      t.text :comment_en
      t.string :name_ukr
      t.text :description_ukr
      t.text :comment_ukr
      t.string :source_code
      t.string :group_code

      t.timestamps
    end
  end
end
