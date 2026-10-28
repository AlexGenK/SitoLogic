class Food < ApplicationRecord
  belongs_to :source, foreign_key: :source_code, primary_key: :code
  belongs_to :group, primary_key: [ :group_type, :code ], foreign_key: [ :group_type, :group_code ], optional: true
end
