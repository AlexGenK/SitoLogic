class FoodsController < ApplicationController
  helper_method :list_params

  def index
    @query = params[:q].to_s.strip
    @source_codes = Array.wrap(params[:sources]).grep(String).compact_blank
    @sources = Source.with_foods_count.order("foods_count DESC", :code)
    foods = Food.order(:name_ukr, :code)
    foods = foods.search_by_name_ukr(@query) if @query.present?
    foods = foods.from_sources(@source_codes) if @source_codes.any?
    @pagy, @foods = pagy(:offset, foods, limit: 15)
  end

  def show
    @food = Food.find(params[:id])
  end

  private
    # Search, filter and page of the list, carried through the food page to return to the same selection
    def list_params
      params.slice(:q, :sources, :page).permit(:q, :page, sources: []).to_h.compact_blank
    end
end
