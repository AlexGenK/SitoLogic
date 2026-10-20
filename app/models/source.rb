class Source < ApplicationRecord
  has_many :foods, primary_key: :code, foreign_key: :source_code
end
