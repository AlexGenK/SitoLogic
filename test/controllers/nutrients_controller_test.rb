require "test_helper"

class NutrientsControllerTest < ActionDispatch::IntegrationTest
  test "index lists groups and shows the first one by default" do
    get nutrients_path

    assert_response :success
    assert_select "#nutrient-groups .nav-link", 3
    assert_select "#nutrient-groups .nav-link.active", /Основні показники/
    assert_select "#nutrients tbody tr", 3
    assert_select "#nutrients tbody tr", "Вода"
  end

  test "index shows nutrients of the selected group" do
    get nutrients_path(group: "vitamins")

    assert_select "#nutrient-groups .nav-link.active", /Вітаміни/
    assert_select "#nutrients tbody tr", count: 1, text: "Ретинол"
  end

  test "other group lists nutrients without a group" do
    get nutrients_path(group: "other")

    assert_select "#nutrients tbody tr", count: 1, text: "Сіалова кислота"
  end

  test "unknown group falls back to the first one" do
    get nutrients_path(group: "nope")

    assert_select "#nutrient-groups .nav-link.active", /Основні показники/
  end
end
