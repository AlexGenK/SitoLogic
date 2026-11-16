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

  test "nutrient_groups skip zero amounts and follow group order with ungrouped last" do
    groups = foods(:one).nutrient_groups
    assert_equal [ "proximates", "vitamins", nil ], groups.map(&:first)
    assert_equal %w[Білки Вода], groups.first.last.map { it.nutrient.long_name_ukr }.sort
    assert_empty foods(:two).nutrient_groups
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

  test "search_by_name_ukr matches every word in any order" do
    assert_equal [ foods(:two) ], Food.search_by_name_ukr("НАН  ба").to_a
    assert_empty Food.search_by_name_ukr("бан ябл")
  end

  test "macros take carbohydrates by weight when the monosaccharide equivalent is missing" do
    by_weight = Nutrient.create!(code: "155", long_name_en: "Available Carbohydrate (weight)",
      med_name_ukr: "Вуглеводи (маса)", long_name_ukr: "Засвоювані вуглеводи (за масою)", unit: :g)
    by_difference = Nutrient.create!(code: "156", long_name_en: "Total Carbohydrate by difference",
      med_name_ukr: "Вуглеводи (різниця)", long_name_ukr: "Загальні вуглеводи за різницею (США)", unit: :g)
    foods(:one).food_nutrients.create!(nutrient: by_weight, amount: 12.5)
    foods(:one).food_nutrients.create!(nutrient: by_difference, amount: 14)

    assert_equal 12.5, Food.macros([ foods(:one).id ])[foods(:one).id][:carbs]
  end
end
