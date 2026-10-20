class Food < ApplicationRecord
  belongs_to :source, foreign_key: :source_code, primary_key: :code
end
