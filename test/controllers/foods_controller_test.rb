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
    rows = css_select("tbody tr").map { |row| row.css("td").map(&:text) }
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
end
