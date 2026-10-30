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
end
