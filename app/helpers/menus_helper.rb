module MenusHelper
  # Weights of protein, fat and carbohydrates in a split: kcal per gram for energy, 1 for weight
  SPLIT_FACTORS = {
    energy: { protein: 4, fat: 9, carbs: 4 },
    weight: { protein: 1, fat: 1, carbs: 1 }
  }.freeze

  def meal_dom_id(menu, day, meal)
    dom_id(menu, "meal_#{day}_#{meal}")
  end

  # Weight and macros with at most one decimal: 150 · 0,3 · 1 250
  def grams(value)
    number_with_precision(value, precision: 1, strip_insignificant_zeros: true, delimiter: " ")
  end

  # Totals of a meal for each set of variants 1..count: variant N of every dish, or the dish's first
  # variant when it has no variant N. Each set is { totals:, item_ids:, fallback: [positions] };
  # totals are energy (kcal) and macros (g)
  def meal_variant_sets(items, count)
    macros = Food.macros(items.map(&:food_id).uniq)
    dishes = items.group_by(&:position).sort.map(&:last)

    (1..count).map do |variant|
      chosen = dishes.map { |dish| dish.find { it.variant == variant } || dish.min_by(&:variant) }
      {
        totals: Nutrient::MACROS.keys.index_with { |key| chosen.sum { (macros.dig(it.food_id, key) || 0) * it.amount / 100 } },
        item_ids: chosen.map(&:id),
        fallback: chosen.reject { it.variant == variant }.map(&:position)
      }
    end
  end

  # Shares of protein, fat and carbohydrates in percent, by energy or by weight; empty when there is none
  def macro_split(totals, by: :energy)
    parts = SPLIT_FACTORS.fetch(by).to_h { |key, factor| [ key, totals[key] * factor ] }
    sum = parts.values.sum
    sum.zero? ? {} : parts.transform_values { (it * 100 / sum).round(1) }
  end
end
