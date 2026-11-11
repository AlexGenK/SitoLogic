require "test_helper"

class NutrientTest < ActiveSupport::TestCase
  test "ukrainian names are required except on import" do
    nutrient = Nutrient.new(code: "999", long_name_en: "Test")

    assert nutrient.valid?(:import)
    assert_not nutrient.valid?
    assert_equal [ :med_name_ukr, :long_name_ukr ], nutrient.errors.attribute_names
  end
end
