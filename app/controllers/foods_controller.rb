class FoodsController < ApplicationController
  helper_method :list_params
  before_action :set_food, only: [ :show, :edit, :update ]

  def index
    @query = params[:q].to_s.strip
    @source_codes = Array.wrap(params[:sources]).grep(String).compact_blank
    @sources = Source.with_foods_count.order("foods_count DESC", :code)
    foods = Food.order(:name_ukr, :code)
    foods = foods.search_by_name_ukr(@query) if @query.present?
    foods = foods.from_sources(@source_codes) if @source_codes.any?
    @pagy, @foods = pagy(:offset, foods, limit: 14)
  end

  def show
  end

  def edit
  end

  def update
    if @food.update(food_params)
      redirect_to food_path(@food, list_params), notice: t(".saved")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_food
      @food = Food.find(params[:id])
    end

    def food_params
      params.expect(food: [ :code, :name_ukr, :description_ukr, :comment_ukr, :group_code ])
    end

    # Search, filter and page of the list, carried through the food page to return to the same selection
    def list_params
      params.slice(:q, :sources, :page).permit(:q, :page, sources: []).to_h.compact_blank
    end
end
