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

  test "index has an edit button in each row" do
    get nutrients_path(group: "vitamins")

    assert_select "tbody td a.btn-sm[href=?][title=?][aria-label=?]",
      edit_nutrient_path(nutrients(:retinol)), "Редагувати нутрієнт", "Редагувати нутрієнт"
  end

  test "show has an edit button" do
    get nutrient_path(nutrients(:retinol))

    assert_select "a.btn-primary[href=?]", edit_nutrient_path(nutrients(:retinol)), text: /Редагувати нутрієнт/
  end

  test "edit offers only the ukrainian names" do
    get edit_nutrient_path(nutrients(:sialic))

    assert_response :success
    assert_select "input[name='nutrient[med_name_ukr]'][value=?]", "Сіалова кислота"
    assert_select "input[name='nutrient[long_name_ukr]'][value=?]", "N-ацетилнейрамінова кислота"
    assert_select "form [name^='nutrient[']", 2
  end

  test "edit responds with not found for unknown nutrient" do
    get edit_nutrient_path(id: 0)

    assert_response :not_found
  end

  test "update saves stripped names and returns to the nutrient page" do
    patch nutrient_path(nutrients(:retinol)), params: { nutrient: { med_name_ukr: " Вітамін A ", long_name_ukr: "Ретинол (вітамін A)" } }

    assert_redirected_to nutrient_path(nutrients(:retinol))
    assert_equal [ "Вітамін A", "Ретинол (вітамін A)" ], nutrients(:retinol).reload.values_at(:med_name_ukr, :long_name_ukr)
    follow_redirect!
    assert_select ".toast[data-controller=toast]", /Нутрієнт збережено\./
  end

  test "update ignores other fields" do
    patch nutrient_path(nutrients(:water)), params: { nutrient: { code: "999", long_name_en: "Hacked", group: "vitamins", med_name_ukr: "Вода" } }

    assert_equal [ "101", "Water", "proximates" ], nutrients(:water).reload.values_at(:code, :long_name_en, :group)
  end

  test "update shows errors next to blank names" do
    patch nutrient_path(nutrients(:water)), params: { nutrient: { med_name_ukr: " ", long_name_ukr: "" } }

    assert_response :unprocessable_content
    assert_select "input.is-invalid[name='nutrient[med_name_ukr]'] + .invalid-feedback", "Вкажіть назву."
    assert_select "input.is-invalid[name='nutrient[long_name_ukr]'] + .invalid-feedback", "Вкажіть повну назву."
    assert_equal "Вода", nutrients(:water).reload.med_name_ukr
  end
end
