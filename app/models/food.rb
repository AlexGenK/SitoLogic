class Food < ApplicationRecord
  belongs_to :source, foreign_key: :source_code, primary_key: :code
  belongs_to :group, primary_key: [ :group_type, :code ], foreign_key: [ :group_type, :group_code ], optional: true

  scope :search_by_name_ukr, ->(query) { where("instr(unicode_lower(name_ukr), ?) > 0", query.downcase) }
end
