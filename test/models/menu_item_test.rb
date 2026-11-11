require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  test "position must fit menu structure" do
    item = menus(:one).menu_items.build(food: foods(:two), day: 1, meal: 5, position: 1, variant: 1, amount: 100)

    assert_not item.valid?
    assert_equal [ :meal ], item.errors.attribute_names
  end

  test "one food per cell" do
    taken = menu_items(:one)
    item = taken.menu.menu_items.build(taken.slice(:day, :meal, :position, :variant).merge(food: foods(:two), amount: 100))

    assert_not item.valid?
    assert item.errors.added?(:variant, :taken, value: taken.variant)
  end

  test "food in a menu cannot be destroyed" do
    assert_not foods(:one).destroy
  end
end
