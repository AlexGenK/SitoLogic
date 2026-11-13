require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup { @menu = menus(:one) }

  test "new renders the picker in the modal frame" do
    get new_menu_menu_item_path(@menu, day: 2, meal: 1, position: 2, variant: 1)
    assert_response :success
    assert_select "turbo-frame#modal h2", "Додати продукт"
    assert_select "turbo-frame#modal", /День 2 · Прийом їжі 1 · Страва 2 · Варіант 1/
    assert_select "input[type=hidden][name='menu_item[position]'][value='2']"
    assert_select "turbo-frame#menu_item_foods p", "Почніть вводити назву продукту."
  end

  test "foods searches by name and source" do
    get foods_menu_menu_items_path(@menu, q: "ябл")
    assert_select "turbo-frame#menu_item_foods input[name='menu_item[food_id]'][value=?]", foods(:one).id.to_s
    assert_select "input[data-protein='0.3']"
    assert_select ".menu-food-list .code", "09003"

    get foods_menu_menu_items_path(@menu, q: "ябл", sources: [ "UKN" ])
    assert_select "p", "Нічого не знайдено."
  end

  test "foods keeps the selected food first and checked" do
    get foods_menu_menu_items_path(@menu, q: "бан", selected: foods(:one).id)
    values = css_select("input[name='menu_item[food_id]']").map { it["value"].to_i }
    assert_equal [ foods(:one).id, foods(:two).id ], values
    assert_select "input[checked][value=?]", foods(:one).id.to_s
  end

  test "create adds the food and replaces the meal card" do
    assert_difference "MenuItem.count" do
      post menu_menu_items_path(@menu), as: :turbo_stream, params: { menu_item: {
        day: 2, meal: 1, position: 1, variant: 1, food_id: foods(:two).id, amount: 120 } }
    end
    assert_turbo_stream action: "replace", target: "meal_2_1_menu_#{@menu.id}"
  end

  test "create without food and weight shows errors in the modal" do
    post menu_menu_items_path(@menu), params: { menu_item: { day: 2, meal: 1, position: 1, variant: 1, amount: "" } }
    assert_response :unprocessable_content
    assert_select "turbo-frame#modal .alert-danger", /Оберіть продукт\./
    assert_select "input.is-invalid[name='menu_item[amount]']"
  end

  test "edit preselects the current food and offers deletion" do
    get edit_menu_menu_item_path(@menu, menu_items(:one))
    assert_select "h2", "Змінити продукт"
    assert_select "input[checked][name='menu_item[food_id]'][value=?]", foods(:one).id.to_s
    assert_select ".menu-food-list label:has(input[checked]) .code", "09003"
    assert_select "input[name='menu_item[amount]'][value='150.0']"
    assert_select "form[data-modal-close] button.btn-outline-danger", "Видалити"
  end

  test "update changes food and weight" do
    patch menu_menu_item_path(@menu, menu_items(:one)), as: :turbo_stream,
      params: { menu_item: { food_id: foods(:two).id, amount: 90 } }
    assert_turbo_stream action: "replace", target: "meal_7_1_menu_#{@menu.id}"
    assert_equal [ foods(:two).id, 90 ], menu_items(:one).reload.values_at(:food_id, :amount)
  end

  test "destroy empties the cell" do
    assert_difference "MenuItem.count", -1 do
      delete menu_menu_item_path(@menu, menu_items(:one)), as: :turbo_stream
    end
    assert_turbo_stream action: "replace", target: "meal_7_1_menu_#{@menu.id}"
  end

  test "item of another menu is not found" do
    other = Menu.create!(code: "M9", name: "Інше", days_count: 1, meals_per_day: 1, items_per_meal: 1, variants_per_item: 1)
    get edit_menu_menu_item_path(other, menu_items(:one))
    assert_response :not_found
  end
end
