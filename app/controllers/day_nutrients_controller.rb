# Nutrients of a menu day: a column per meal for the variant set its card shows, and the day's total.
# Rendered into the day_nutrients frame of the menu page; variants[] has one set number per meal.
class DayNutrientsController < ApplicationController
  def show
    @menu = Menu.find(params[:menu_id])
    @day = params[:day].to_i.clamp(1, @menu.days_count)
    requested = Array.wrap(params[:variants]).grep(String).map(&:to_i)
    @variants = (1..@menu.meals_per_day).map { |meal| requested[meal - 1].to_i.clamp(1, @menu.variants_per_item) }

    cells = @menu.cells(@day)
    @foods_present = cells.any?
    @groups = helpers.day_nutrient_groups(@menu, cells, @variants)
  end
end
