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

  test "index links nutrients to their pages" do
    get nutrients_path(group: "vitamins")

    assert_select "#nutrients a[href=?]", nutrient_path(nutrients(:retinol)), "Ретинол"
  end

  test "show displays the group with a link back to it" do
    get nutrient_path(nutrients(:retinol))

    assert_response :success
    assert_select "h1", "Ретинол"
    assert_select "dd", "Вітаміни"
    assert_select "a[href=?]", nutrients_path(group: "vitamins")
  end

  test "show displays both names and links a nutrient without a group back to the other group" do
    get nutrient_path(nutrients(:sialic))

    assert_select "h1", "Сіалова кислота"
    assert_select "dd", "Сіалова кислота"
    assert_select "dd", "N-ацетилнейрамінова кислота"
    assert_select "dd", "Інше"
    assert_select "a[href=?]", nutrients_path(group: "other")
  end
end
