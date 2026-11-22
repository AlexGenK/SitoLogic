require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "structure sizes must be positive" do
    menu = Menu.new(code: "M2", name: "Test", days_count: 0, meals_per_day: 1, items_per_meal: 1, variants_per_item: 1)

    assert_not menu.valid?
    assert_equal [ :days_count ], menu.errors.attribute_names
  end

  test "cannot shrink structure below filled items" do
    menu = menus(:one)

    menu.days_count = 6
    assert_not menu.valid?
    assert menu.errors.added?(:days_count, :items_outside)

    menu.days_count = 8
    assert menu.valid?
  end

  test "total_amount averages variants of a dish" do
    menu = menus(:one)
    menu.menu_items.create!(day: 7, meal: 1, position: 1, variant: 2, food: foods(:two), amount: 100)
    menu.menu_items.create!(day: 1, meal: 2, position: 1, variant: 1, food: foods(:one), amount: 50)
    assert_equal 175, menu.total_amount
    assert_equal 87.5, menu.average_daily_amount   # 2 filled days
  end

  test "filled_counts counts days, meals and dishes with foods" do
    menu = menus(:one)
    menu.menu_items.create!(day: 7, meal: 1, position: 1, variant: 2, food: foods(:two), amount: 100)
    menu.menu_items.create!(day: 1, meal: 2, position: 1, variant: 1, food: foods(:one), amount: 50)
    assert_equal({ days: 2, meals: 2, dishes: 2 }, menu.filled_counts)
  end

  test "nutrient_totals averages variants of a dish and skips zeros" do
    menu = menus(:one)
    menu.menu_items.create!(day: 7, meal: 1, position: 1, variant: 2, food: foods(:two), amount: 100)
    menu.menu_items.create!(day: 1, meal: 2, position: 1, variant: 1, food: foods(:one), amount: 50)
    totals = menu.nutrient_totals
    assert_in_delta 106.875, totals[nutrients(:water)]   # 85.5 × 1.5 / 2 + 85.5 × 0.5
    assert_in_delta 0.375, totals[nutrients(:protein)]
    assert_not totals.key?(nutrients(:fat))
  end
end
