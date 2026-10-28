class AddGroupType < ActiveRecord::Migration[8.1]
  def change
    add_column :sources, :group_type, :string
    add_index :sources, :group_type

    rename_column :groups, :source_code, :group_type
    add_index :groups, [ :group_type, :code ], unique: true

    add_column :foods, :group_type, :string
    add_index :foods, [ :group_type, :group_code ]
  end
end
