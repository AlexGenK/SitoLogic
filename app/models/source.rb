class Source < ApplicationRecord
  has_many :foods, primary_key: :code, foreign_key: :source_code
  has_many :groups, primary_key: :group_type, foreign_key: :group_type
end
