class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.json :default_source_codes, null: false, default: []

      t.timestamps
    end
  end
end
