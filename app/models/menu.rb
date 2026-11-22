class Menu < ApplicationRecord
  STRUCTURE = {
    days_count: :day,
    meals_per_day: :meal,
    items_per_meal: :position,
    variants_per_item: :variant
  }.freeze

  has_many :menu_items, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates(*STRUCTURE.keys, numericality: { only_integer: true, greater_than: 0 })
  validate :structure_fits_items, on: :update

  # Filled cells of a day keyed by [meal, position, variant]
  def cells(day)
    menu_items.where(day:).includes(:food).index_by { [ it.meal, it.position, it.variant ] }
  end

  # Weight of the menu in grams: a dish with several variants counts as the mean of its variants
  def total_amount
    menu_items.group(:day, :meal, :position).average(:amount).values.sum(0)
  end

  # Mean weight per filled day (a day with at least one food)
  def average_daily_amount
    days = filled_counts[:days]
    days.zero? ? 0 : total_amount / days
  end

  # Numbers of filled days, meals and dishes: the divisors of the report's averages
  def filled_counts
    dishes = menu_items.distinct.pluck(:day, :meal, :position)
    { days: dishes.map(&:first).uniq.size, meals: dishes.map { it.first(2) }.uniq.size, dishes: dishes.size }
  end

  # Nutrients of the whole menu as { nutrient => amount }: a dish counts as the mean of its variants, a variant
  # without the nutrient counts as zero. Zero totals are skipped.
  def nutrient_totals
    items = menu_items.to_a
    variants = items.group_by { [ it.day, it.meal, it.position ] }.transform_values(&:size)
    rows = FoodNutrient.where(food_id: items.map(&:food_id).uniq).includes(:nutrient).group_by(&:food_id)

    totals = Hash.new(0)
    items.each do |item|
      share = item.amount / 100 / variants[[ item.day, item.meal, item.position ]]
      rows.fetch(item.food_id, []).each { |row| totals[row.nutrient] += row.amount * share }
    end
    totals.reject { |_, amount| amount.zero? }
  end

  private
    # Не дає зменшити сітку, якщо заповнені клітинки опиняться за її межами.
    def structure_fits_items
      STRUCTURE.each do |attribute, column|
        max = public_send(attribute)
        next unless max.is_a?(Integer) && will_save_change_to_attribute?(attribute)

        if menu_items.where(column => (max + 1)..).exists?
          errors.add(attribute, :items_outside)
        end
      end
    end
end
