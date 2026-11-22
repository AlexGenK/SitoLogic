require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "edit lists sources with checked defaults and marks the navbar link" do
    settings(:main).update!(default_source_codes: [ "USD" ])
    get edit_settings_path
    assert_response :success
    assert_select "nav.app-navbar a.nav-link.active[href=?]", edit_settings_path
    assert_select "input[type=checkbox][name='setting[default_source_codes][]']", 2
    assert_select "input[type=checkbox][value=USD][checked]"
  end

  test "update saves default sources" do
    patch settings_path, params: { setting: { default_source_codes: [ "", "UKN" ] } }
    assert_redirected_to edit_settings_path
    assert_equal [ "UKN" ], Setting.current.default_source_codes
    follow_redirect!
    assert_select ".toast", /Налаштування збережено\./
  end

  test "update clears default sources" do
    settings(:main).update!(default_source_codes: [ "USD" ])
    patch settings_path, params: { setting: { default_source_codes: [ "" ] } }
    assert_equal [], Setting.current.default_source_codes
  end

  test "update rejects unknown sources" do
    patch settings_path, params: { setting: { default_source_codes: [ "XXX" ] } }
    assert_response :unprocessable_content
    assert_select ".alert-danger", "Серед обраних є невідомі джерела."
  end
end
