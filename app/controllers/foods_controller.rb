class FoodsController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @source_codes = Array.wrap(params[:sources]).grep(String).compact_blank
    @sources = Source.with_foods_count.order("foods_count DESC", :code)
    foods = Food.order(:name_ukr, :code)
    foods = foods.search_by_name_ukr(@query) if @query.present?
    foods = foods.from_sources(@source_codes) if @source_codes.any?
    @pagy, @foods = pagy(:offset, foods, limit: 15)
  end
end
