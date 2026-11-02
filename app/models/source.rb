class Source < ApplicationRecord
  has_many :foods, primary_key: :code, foreign_key: :source_code
  has_many :groups, primary_key: :group_type, foreign_key: :group_type

  scope :with_foods_count, -> { joins(:foods).group(:id).select("sources.*, COUNT(foods.id) AS foods_count") }

  def display_name
    name_ukr.presence || name_en
  end
end
