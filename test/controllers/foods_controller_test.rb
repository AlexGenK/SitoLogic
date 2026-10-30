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
    assert_equal [ [ "MyString", "09040", "Банан" ], [ "MyString", "09003", "Яблуко" ] ], rows
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
end
