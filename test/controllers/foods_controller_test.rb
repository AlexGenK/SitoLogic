require "test_helper"

class FoodsControllerTest < ActionDispatch::IntegrationTest
  test "index renders navbar with active foods link" do
    get foods_path
    assert_response :success
    assert_select "nav.app-navbar a.nav-link.active[aria-current=page][href=?]", foods_path, text: "Продукти"
  end
end
