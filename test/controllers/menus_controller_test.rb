require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  test "index lists menus and marks the menus nav link active" do
    get menus_path
    assert_response :success
    assert_select "nav.app-navbar a.nav-link.active[href=?]", menus_path, text: "Меню"
    assert_select "tbody td a[href=?]", menu_path(menus(:one)), text: "Тижневе меню"
  end

  test "index shows empty state" do
    MenuItem.delete_all
    Menu.delete_all
    get menus_path
    assert_select "p", "Меню ще немає."
    assert_select "a.btn-primary[href=?]", new_menu_path, text: "Створити меню"
  end

  test "show renders day pills and a card per meal with dish slots" do
    get menu_path(menus(:one), day: 7)
    assert_response :success
    assert_select ".nav-pills .nav-link", 7
    assert_select ".nav-pills .nav-link.active", "День 7"
    assert_select ".card-header h2", 4
    assert_select "#meal_7_1_menu_#{menus(:one).id} .list-group-item", 3
    assert_select "a[data-turbo-frame=modal][href=?]", edit_menu_menu_item_path(menus(:one), menu_items(:one)), text: /Яблуко · 150 г/
    assert_select "a[href=?]", new_menu_menu_item_path(menus(:one), day: 7, meal: 1, position: 1, variant: 2), text: /Додати варіант/
  end

  test "show clamps day to the menu" do
    get menu_path(menus(:one), day: 99)
    assert_select ".nav-pills .nav-link.active", "День 7"
  end

  test "show sums first variants of a meal" do
    get menu_path(menus(:one), day: 7)
    assert_select ".card-footer", /0 ккал · Б 0,5 · Ж 0 · В 0 г/
    assert_select ".card-footer", /Частка енергії: Б 100 % · Ж 0 % · В 0 %/
    assert_select ".card-footer", /Частка маси: Б 100 % · Ж 0 % · В 0 %/
    assert_select ".card-footer [data-meal-variants-target=set]:not([hidden]) .progress-stacked", 2
  end

  test "show switches meal totals between variant sets" do
    get menu_path(menus(:one), day: 7)
    card = "#meal_7_1_menu_#{menus(:one).id}"
    assert_select "#{card}[data-controller=meal-variants]"
    assert_select "#{card} [data-meal-variants-target=label]", "Варіант 1 з 2"
    assert_select "#{card} [data-meal-variants-target=set]", 2
    assert_select "#{card} [data-meal-variants-target=set][hidden]", 1
    assert_select "#{card} [data-meal-variants-target=set][hidden] .form-text",
      "Без варіанта 2 (страви 1) враховано перший варіант."
    assert_select "#{card} a.menu-variant-chosen[data-item-id=?]", menu_items(:one).id.to_s
  end

  test "show counts the second variant where it exists" do
    second = menus(:one).menu_items.create!(day: 7, meal: 1, position: 1, variant: 2, food: foods(:two), amount: 100)
    get menu_path(menus(:one), day: 7)
    assert_select "[data-meal-variants-target=set][hidden][data-items=?]", [ second.id ].to_json
  end

  test "show has no variant switcher for a menu with one variant per dish" do
    menu = Menu.create!(code: "M3", name: "Одноваріантне", days_count: 1, meals_per_day: 1, items_per_meal: 1, variants_per_item: 1)
    menu.menu_items.create!(day: 1, meal: 1, position: 1, variant: 1, food: foods(:one), amount: 100)
    get menu_path(menu)
    assert_select "[data-controller=meal-variants]", 0
    assert_select ".card-footer", /Частка маси/
  end

  test "create saves a menu and opens it" do
    assert_difference "Menu.count" do
      post menus_path, params: { menu: { code: "M2", name: "Нове", days_count: 3, meals_per_day: 3, items_per_meal: 2, variants_per_item: 1 } }
    end
    assert_redirected_to menu_path(Menu.find_by!(code: "M2"))
  end

  test "create shows errors" do
    post menus_path, params: { menu: { code: "M1", name: "", days_count: 0, meals_per_day: 1, items_per_meal: 1, variants_per_item: 1 } }
    assert_response :unprocessable_content
    assert_select "input.is-invalid[name='menu[code]'] + .invalid-feedback", "Меню з таким кодом уже є."
    assert_select "input.is-invalid[name='menu[days_count]']"
  end

  test "update refuses to shrink below filled cells" do
    patch menu_path(menus(:one)), params: { menu: { days_count: 6 } }
    assert_response :unprocessable_content
    assert_select ".invalid-feedback", "У меню є страви в днях за межами нової кількості."
    assert_equal 7, menus(:one).reload.days_count
  end
end
