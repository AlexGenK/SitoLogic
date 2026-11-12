class Food < ApplicationRecord
  belongs_to :source, foreign_key: :source_code, primary_key: :code
  belongs_to :group, primary_key: [ :group_type, :code ], foreign_key: [ :group_type, :group_code ], optional: true
  has_many :food_nutrients, dependent: :destroy
  has_many :nutrients, through: :food_nutrients
  has_many :menu_items, dependent: :restrict_with_error

  # Every word of the query must occur in name_ukr, in any order and case
  scope :search_by_name_ukr, ->(query) {
    query.downcase.split.inject(all) { |foods, word| foods.where("instr(unicode_lower(name_ukr), ?) > 0", word) }
  }
  scope :from_sources, ->(codes) { where(source_code: codes) }

  # Per-100 g macros of the given foods: { food_id => { energy:, protein:, fat:, carbs: } }; missing values are nil
  def self.macros(ids)
    amounts = FoodNutrient.joins(:nutrient)
      .where(food_id: ids, nutrients: { code: Nutrient::MACROS.values.flatten })
      .pluck(:food_id, "nutrients.code", :amount)
      .group_by(&:first)
      .transform_values { |rows| rows.to_h { |_, code, amount| [ code, amount ] } }

    ids.index_with do |id|
      values = amounts.fetch(id, {})
      Nutrient::MACROS.transform_values { |codes| values.values_at(*codes).compact.first }
    end
  end

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
