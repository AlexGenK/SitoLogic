class Group < ApplicationRecord
  has_many :sources, primary_key: :group_type, foreign_key: :group_type
  has_many :foods, primary_key: [ :group_type, :code ], foreign_key: [ :group_type, :group_code ]
end
