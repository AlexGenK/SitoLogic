require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "current returns the only row" do
    assert_equal settings(:main), Setting.current
    assert_no_difference("Setting.count") { Setting.current }
  end

  test "current creates the row with defaults when there is none" do
    Setting.delete_all
    assert_difference("Setting.count") { assert_equal [], Setting.current.default_source_codes }
  end

  test "normalizes source codes" do
    setting = Setting.new(default_source_codes: [ "USD", "", "USD", nil ])
    assert_equal [ "USD" ], setting.default_source_codes
  end

  test "rejects unknown source codes" do
    setting = Setting.current
    assert_not setting.update(default_source_codes: [ "USD", "XXX" ])
    assert_equal [ "Серед обраних є невідомі джерела." ], setting.errors[:default_source_codes]
  end
end
