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

  # Percent with at most two decimals: 100 · 12,5 · 0,04
  def percent_share(value)
    number_with_precision(value, precision: 2, strip_insignificant_zeros: true, delimiter: " ")
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
        .then { group_nutrient_rows(it) }
    end
  end

  # Nutrients of a day with one variant set per meal: [[group, [[nutrient, [amount per meal], total]]]];
  # a meal without the nutrient has nil, nutrients with a zero total are skipped
  def day_nutrient_groups(menu, cells, variants)
    per_meal = variants.map.with_index(1) do |variant, meal|
      items = cells.values.select { it.meal == meal }
      meal_nutrient_sets(items, menu.variants_per_item)[variant - 1].flat_map(&:last).to_h { |nutrient, amount, *| [ nutrient, amount ] }
    end

    rows = per_meal.flat_map(&:keys).uniq.map { |nutrient| [ nutrient, per_meal.map { it[nutrient] }, per_meal.sum { it[nutrient] || 0 } ] }
    group_nutrient_rows(rows.reject { |_, _, total| total.zero? })
  end

  # Rows that start with a nutrient, as [[group, rows]] in Nutrient::GROUPS order (ungrouped last), by nutrient id
  def group_nutrient_rows(rows)
    rows.sort_by { |nutrient, *| nutrient.id }
      .group_by { |nutrient, *| nutrient.group }
      .sort_by { |group, _| Nutrient.groups.keys.index(group) || Nutrient.groups.size }
  end

  # Rows of the menu report as { key => value } in display order; the label of a row is t("menus.report.<key>")
  def menu_report_rows(menu)
    total = menu.total_amount
    {
      code: menu.code,
      name: menu.name,
      items_count: menu.menu_items.count.to_s,
      total_amount: t("menus.report.grams", value: grams(total)),
      daily_amount: t("menus.report.grams", value: grams(menu.average_daily_amount)),
      structure: [
        t("menus.report.days", count: menu.days_count),
        t("menus.report.meals", count: menu.meals_per_day),
        t("menus.report.dishes", count: menu.items_per_meal),
        t("menus.report.variants", count: menu.variants_per_item)
      ].join(" · ")
    }
  end

  # Nutrients of the menu report: [[group, [[nutrient, total, per_day, per_meal, per_dish]]]] in Nutrient::GROUPS
  # order; the averages are over the filled days, meals and dishes
  def menu_report_nutrient_groups(menu)
    divisors = menu.filled_counts.values_at(:days, :meals, :dishes)
    rows = menu.nutrient_totals.map { |nutrient, total| [ nutrient, total, *divisors.map { total / it } ] }
    group_nutrient_rows(rows)
  end

  # The same groups as text for the PDF: [[group label, [[name, unit, total, per_day, per_meal, per_dish]]]]
  def menu_report_nutrient_text(groups)
    groups.map do |_, rows|
      [
        rows.first.first.group_ukr || t("foods.nutrients.other_group"),
        rows.map { |nutrient, *amounts| [ nutrient.display_name, nutrient.unit_ukr.to_s, *amounts.map { nutrient_sum(it) } ] }
      ]
    end
  end

  # Foods of the menu report: [[food, grams, percent of the menu's weight]], by percent ascending, then by name
  def menu_report_foods(menu)
    amounts = menu.food_amounts
    total = amounts.values.sum(0)
    amounts.map { |food, amount| [ food, amount, amount * 100 / total ] }
      .sort_by { |food, _, share| [ share, food.name_ukr ] }
  end
end
