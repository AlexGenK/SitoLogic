require "test_helper"

class FoodTest < ActiveSupport::TestCase
  test "code is required and unique only within a source" do
    food = foods(:two)

    food.code = " "
    assert_not food.valid?
    assert_equal [ "Вкажіть код." ], food.errors[:code]

    food.code = foods(:one).code
    assert food.valid?

    food = foods(:one).dup
    assert_not food.valid?
    assert_equal [ "Такий код уже є в цьому джерелі." ], food.errors[:code]
  end

  test "name_ukr is required" do
    food = foods(:one)
    food.name_ukr = ""
    assert_not food.valid?
    assert_equal [ "Вкажіть назву." ], food.errors[:name_ukr]
  end

  test "group must belong to the group type of the source" do
    food = foods(:one)

    food.group_code = "B"
    assert food.valid?

    food.group_code = "C"
    assert_not food.valid?
    assert_equal [ "Ця група не дозволена для джерела продукту." ], food.errors[:group_code]
  end

  test "source without group type allows no group" do
    food = foods(:two)
    assert_empty food.available_groups

    food.group_code = "A"
    assert_not food.valid?
  end

  test "blank group_code is stored as nil" do
    food = foods(:one)
    food.group_code = ""
    assert_nil food.group_code
    assert food.valid?
  end

  test "available_groups are the groups of the source sorted by code" do
    assert_equal [ "A", "B" ], foods(:one).available_groups.map(&:code)
  end
end
