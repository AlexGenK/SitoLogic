module FoodsHelper
  # Source amounts have at most 3 decimals: 87,8 · 0,004 · 1 322 000
  def nutrient_amount(amount)
    number_with_precision(amount, precision: 3, strip_insignificant_zeros: true, delimiter: " ")
  end
end
