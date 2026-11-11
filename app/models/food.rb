class Food < ApplicationRecord
  belongs_to :source, foreign_key: :source_code, primary_key: :code
  belongs_to :group, primary_key: [ :group_type, :code ], foreign_key: [ :group_type, :group_code ], optional: true
  has_many :food_nutrients, dependent: :destroy
  has_many :nutrients, through: :food_nutrients

  scope :search_by_name_ukr, ->(query) { where("instr(unicode_lower(name_ukr), ?) > 0", query.downcase) }
  scope :from_sources, ->(codes) { where(source_code: codes) }

  normalizes :code, :name_ukr, :group_code, with: ->(value) { value.strip.presence }

  validates :code, presence: true, uniqueness: { scope: :source_code }
  validates :name_ukr, presence: true
  validate :group_allowed_by_source

  def available_groups
    source.groups.order(:code)
  end

  # Non-zero nutrient amounts as [[group, food_nutrients], …] in Nutrient::GROUPS order;
  # nutrients without a group come last under nil. Zero amounts are never shown.
  def nutrient_groups
    food_nutrients.where.not(amount: 0).includes(:nutrient).order(:nutrient_id)
      .group_by { it.nutrient.group }
      .sort_by { |group, _| Nutrient.groups.keys.index(group) || Nutrient.groups.size }
  end

  private
    def group_allowed_by_source
      return if group_code.nil? || source.nil?

      errors.add(:group_code, :inclusion) unless source.groups.exists?(code: group_code)
    end
end
