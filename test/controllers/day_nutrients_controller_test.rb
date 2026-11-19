require "test_helper"

class DayNutrientsControllerTest < ActionDispatch::IntegrationTest
  setup { @menu = menus(:one) }

  def row(name)
    css_select("tbody tr").map { |tr| tr.css("td").map { it.text.strip } }.find { it.first == name }
  end

  test "show sums a day with the first sets by default" do
    get menu_day_nutrients_path(@menu, 7)
    assert_response :success
    assert_select "turbo-frame#day_nutrients h2", "Нутрієнти за день 7"
    assert_select "turbo-frame#day_nutrients", /Набори: 1 · 1 · 1 · 1/
    assert_select "thead th", /Прийом 1\s+варіант 1/
    assert_equal [ "Вода", "128", "—", "—", "—", "128", "г" ], row("Вода")
    assert_select ".badge", 0
  end

  test "show takes the set of each meal from variants" do
    @menu.menu_items.create!(day: 7, meal: 1, position: 1, variant: 2, food: foods(:two), amount: 100)
    get menu_day_nutrients_path(@menu, 7, variants: [ 2, 1, 1, 1 ])
    assert_select "turbo-frame#day_nutrients", /Набори: 2 · 1 · 1 · 1/
    assert_select "p", "Даних про нутрієнти за цей день немає."
  end

  test "show keeps set numbers within the menu" do
    get menu_day_nutrients_path(@menu, 7, variants: [ 9, 0 ])
    assert_select "turbo-frame#day_nutrients", /Набори: 2 · 1 · 1 · 1/
  end

  test "show says when a day has no foods" do
    get menu_day_nutrients_path(@menu, 1)
    assert_select "p", "У цьому дні ще немає продуктів."
  end
end
