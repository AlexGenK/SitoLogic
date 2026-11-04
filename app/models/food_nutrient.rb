class FoodNutrient < ApplicationRecord
  belongs_to :food
  belongs_to :nutrient

  validates :amount, numericality: true
end
