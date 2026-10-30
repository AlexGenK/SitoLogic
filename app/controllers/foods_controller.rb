class FoodsController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    foods = Food.order(:name_ukr, :code)
    foods = foods.search_by_name_ukr(@query) if @query.present?
    @pagy, @foods = pagy(:offset, foods, limit: 15)
  end
end
