require "test_helper"

class FoodsControllerTest < ActionDispatch::IntegrationTest
  test "index renders navbar with active foods link" do
    get foods_path
    assert_response :success
    assert_select "nav.app-navbar a.nav-link.active[aria-current=page][href=?]", foods_path, text: "Продукти"
  end

  test "index lists foods sorted by name_ukr" do
    get foods_path
    assert_response :success
    rows = css_select("tbody tr").map { |row| row.css("td").first(3).map(&:text) }
    assert_equal [ [ "UKN", "09040", "Банан" ], [ "USD", "09003", "Яблуко" ] ], rows
  end

  test "index searches name_ukr case-insensitively" do
    get foods_path(q: " бАН ")
    assert_response :success
    assert_select "input[name=q][value=?]", "бАН"
    assert_select "tbody tr", 1
    assert_select "tbody td", "Банан"
  end

  test "index shows not found message for search without results" do
    get foods_path(q: "груша")
    assert_response :success
    assert_select "table", 0
    assert_select "p", "Нічого не знайдено."
  end

  test "index filters foods by one source" do
    get foods_path(sources: [ "USD" ])
    assert_response :success
    assert_select "tbody tr", 1
    assert_select "tbody td", "Яблуко"
    assert_select "input[type=checkbox][name='sources[]'][value=USD][checked]"
    assert_select "button .badge", "1"
  end

  test "index filters foods by several sources" do
    get foods_path(sources: [ "USD", "UKN" ])
    assert_select "tbody tr", 2
    assert_select "button .badge", "2"
  end

  test "index combines source filter with search" do
    get foods_path(q: "бан", sources: [ "USD" ])
    assert_select "table", 0
    assert_select "p", "Нічого не знайдено."
  end

  test "index lists only sources with foods and falls back to name_en" do
    get foods_path
    assert_select "input[name='sources[]']", 2
    assert_select "input[name='sources[]'][value=ADF]", 0
    assert_select ".source-filter-menu", /UK Nutrient Databank/
  end

  test "index keeps selected sources in pagination links" do
    16.times { |i| Food.create!(code: "x#{i}", source_code: "USD", name_ukr: "Їжа #{i}") }
    get foods_path(sources: [ "USD" ])
    assert_select "a.page-link[href*=?]", "sources%5B%5D=USD"
  end

  test "index ignores malformed sources param" do
    get foods_path(sources: { a: "b" })
    assert_response :success
    assert_select "tbody tr", 2
  end

  test "index links food name to its page and keeps list params" do
    get foods_path(q: "банан", sources: [ "UKN" ], page: 1)
    assert_select "tbody td a[href=?]", food_path(foods(:two), q: "банан", sources: [ "UKN" ], page: 1), text: "Банан"
  end

  test "show displays full food information" do
    get food_path(foods(:one))
    assert_response :success
    assert_select "h1", "Яблуко"
    assert_select "dd", "Свіжі яблука"
    assert_select "dd", "Середні значення за сезон"
    assert_select "dd .badge", "USD"
    assert_select "dd", /Міністерство сільського господарства США/
    assert_select "dd .badge", "A"
    assert_select "dd", /Фрукти/
  end

  test "show handles food without group, description and comment" do
    get food_path(foods(:two))
    assert_response :success
    assert_select "dd", /UK Nutrient Databank/
    assert_select "dd", "Без групи"
    assert_select "p", "Опису й коментаря немає."
    assert_select "dt", { text: "Опис", count: 0 }
    assert_select "dt", { text: "Коментар", count: 0 }
  end

  test "show back link returns to the same list selection" do
    get food_path(foods(:one), q: "ябл", sources: [ "USD" ], page: 2)
    assert_select "a.btn[href=?]", foods_path(q: "ябл", sources: [ "USD" ], page: 2), text: "Назад до списку"
  end

  test "show back link leads to the plain list without params" do
    get food_path(foods(:one))
    assert_select "a.btn[href=?]", foods_path, text: "Назад до списку"
    assert_select "a.btn i.bi-arrow-left[aria-hidden=true]"
  end

  test "show responds with not found for unknown food" do
    get food_path(id: 0)
    assert_response :not_found
  end

  test "index has an edit button in each row that keeps list params" do
    get foods_path(q: "банан")
    assert_select "tbody td a.btn-sm[href=?][title=?][aria-label=?]",
      edit_food_path(foods(:two), q: "банан"), "Редагувати продукт", "Редагувати продукт"
  end

  test "show has an edit button that keeps list params" do
    get food_path(foods(:one), q: "ябл")
    assert_select "a.btn-primary[href=?]", edit_food_path(foods(:one), q: "ябл"), text: /Редагувати продукт/
  end

  test "edit offers only groups of the food source" do
    get edit_food_path(foods(:one))
    assert_response :success
    assert_select "input[name='food[code]'][value=?]", "09003"
    assert_select "select[name='food[group_code]']:not([disabled]) option", 3
    assert_select "option[selected][value=A]", "A — Фрукти"
    assert_select "option[value=C]", 0
    assert_select "option[value='']", "Без групи"
  end

  test "edit disables group select for source without groups" do
    get edit_food_path(foods(:two))
    assert_response :success
    assert_select "select[name='food[group_code]'][disabled]"
    assert_select ".form-text", "Це джерело не використовує групи."
  end

  test "edit does not offer source or english fields" do
    get edit_food_path(foods(:one))
    assert_select "[name='food[source_code]']", 0
    assert_select "[name='food[name_en]']", 0
  end

  test "edit responds with not found for unknown food" do
    get edit_food_path(id: 0)
    assert_response :not_found
  end

  test "update saves fields and returns to the food page with list params" do
    patch food_path(foods(:one), q: "ябл"), params: { food: {
      code: "09999", name_ukr: "Яблуко зелене", description_ukr: "Новий опис", comment_ukr: "Новий коментар", group_code: "B"
    } }
    assert_redirected_to food_path(foods(:one), q: "ябл")

    food = foods(:one).reload
    assert_equal [ "09999", "Яблуко зелене", "Новий опис", "Новий коментар", "B" ],
      food.values_at(:code, :name_ukr, :description_ukr, :comment_ukr, :group_code)

    follow_redirect!
    assert_select ".toast[data-controller=toast]", /Продукт збережено\./
  end

  test "update clears the group" do
    patch food_path(foods(:one)), params: { food: { group_code: "" } }
    assert_nil foods(:one).reload.group_code
  end

  test "update ignores source and english fields" do
    patch food_path(foods(:one)), params: { food: { source_code: "UKN", group_type: "GPS", name_en: "Hacked", name_ukr: "Яблуко" } }
    food = foods(:one).reload
    assert_equal [ "USD", "GPM", "Apples, raw" ], food.values_at(:source_code, :group_type, :name_en)
  end

  test "update rejects a group of another type" do
    patch food_path(foods(:one)), params: { food: { group_code: "C" } }
    assert_response :unprocessable_content
    assert_select ".invalid-feedback", "Ця група не дозволена для джерела продукту."
    assert_equal "A", foods(:one).reload.group_code
  end

  test "update shows errors next to the fields and keeps entered values" do
    Food.create!(code: "01001", source_code: "USD", name_ukr: "Інший продукт")
    patch food_path(foods(:one)), params: { food: { code: "01001", name_ukr: "", description_ukr: "Чернетка" } }
    assert_response :unprocessable_content
    assert_select "input.is-invalid[name='food[code]'][value=?] + .invalid-feedback", "01001", text: "Такий код уже є в цьому джерелі."
    assert_select "input.is-invalid[name='food[name_ukr]'] + .invalid-feedback", "Вкажіть назву."
    assert_select "textarea[name='food[description_ukr]']", /Чернетка/
    assert_equal "09003", foods(:one).reload.code
  end
end
