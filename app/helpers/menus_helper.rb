module MenusHelper
  # Weights of protein, fat and carbohydrates in a split: kcal per gram for energy, 1 for weight
  SPLIT_FACTORS = {
    energy: { protein: 4, fat: 9, carbs: 4 },
    weight: { protein: 1, fat: 1, carbs: 1 }
  }.freeze

  def meal_dom_id(menu, day, meal)
    dom_id(menu, "meal_#{day}_#{meal}")
  end

  def meal_nutrients_dom_id(menu, day, meal)
    dom_id(menu, "meal_nutrients_#{day}_#{meal}")
  end

  # Weight and macros with at most one decimal: 150 · 0,3 · 1 250
  def grams(value)
    number_with_precision(value, precision: 1, strip_insignificant_zeros: true, delimiter: " ")
  end

  # Summed nutrient amounts, 3 significant digits: 1 120 · 14,2 · 0,452
  def nutrient_sum(value)
    number_with_precision(value, precision: 3, significant: true, strip_insignificant_zeros: true, delimiter: " ")
  end

  # Items counted in each set of variants 1..count: variant N of every dish, or the dish's first variant
  # when it has no variant N
  def variant_choices(items, count)
    dishes = items.group_by(&:position).sort.map(&:last)
    (1..count).map { |variant| dishes.map { |dish| dish.find { it.variant == variant } || dish.min_by(&:variant) } }
  end

  # Totals of a meal for each set of variants 1..count: variant N of every dish, or the dish's first
  # variant when it has no variant N. Each set is { totals:, item_ids:, fallback: [positions] };
  # totals are energy (kcal) and macros (g)
  def meal_variant_sets(items, count)
    macros = Food.macros(items.map(&:food_id).uniq)

    variant_choices(items, count).map.with_index(1) do |chosen, variant|
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

  # Summed nutrients of a meal for each set of variants: [[group, [[nutrient, amount, counted, total, missing]]]] in
  # Nutrient::GROUPS order, ungrouped last. counted is how many of the set's foods have a value for the
  # nutrient (an explicit zero counts), total how many foods the set has, missing the foods without a value.
  # Zero sums are skipped.
  def meal_nutrient_sets(items, count)
    rows = FoodNutrient.where(food_id: items.map(&:food_id).uniq).includes(:nutrient).group_by(&:food_id)

    variant_choices(items, count).map do |chosen|
      sums = Hash.new { |hash, nutrient| hash[nutrient] = [ 0, [] ] }
      chosen.each do |item|
        rows.fetch(item.food_id, []).each do |row|
          sum = sums[row.nutrient]
          sum[0] += row.amount * item.amount / 100
          sum[1] << item
        end
      end

      sums.reject { |_, (amount, _)| amount.zero? }
        .map { |nutrient, (amount, counted)| [ nutrient, amount, counted.size, chosen.size, (chosen - counted).map(&:food) ] }
        .sort_by { |nutrient, *| nutrient.id }
        .group_by { |nutrient, *| nutrient.group }
        .sort_by { |group, _| Nutrient.groups.keys.index(group) || Nutrient.groups.size }
    end
  end
end
