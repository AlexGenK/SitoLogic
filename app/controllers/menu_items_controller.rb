class MenuItemsController < ApplicationController
  FOODS_LIMIT = 2000

  before_action :set_menu
  before_action :set_menu_item, only: [ :edit, :update, :destroy ]

  def new
    @menu_item = @menu.menu_items.build(params.permit(:day, :meal, :position, :variant))
    prepare_modal
  end

  def create
    @menu_item = @menu.menu_items.build(params.expect(menu_item: [ :day, :meal, :position, :variant, :food_id, :amount ]))
    if @menu_item.save
      respond_with_meal
    else
      prepare_modal
      render :new, status: :unprocessable_content
    end
  end

  def edit
    prepare_modal
  end

  def update
    if @menu_item.update(params.expect(menu_item: [ :food_id, :amount ]))
      respond_with_meal
    else
      prepare_modal
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @menu_item.destroy!
    respond_with_meal
  end

  # Search results for the picker, loaded into the menu_item_foods frame
  def foods
    find_foods(selected_id: params[:selected].presence&.to_i)
  end

  private
    def set_menu
      @menu = Menu.find(params[:menu_id])
    end

    def set_menu_item
      @menu_item = @menu.menu_items.find(params[:id])
    end

    def prepare_modal
      @sources = Source.with_foods_count.order("foods_count DESC", :code)
      find_foods(selected_id: @menu_item.food_id)
    end

    # Foods matching q and sources; the selected food is always listed first
    def find_foods(selected_id:)
      @query = params[:q].to_s.strip
      @source_codes = Array.wrap(params[:sources]).grep(String).compact_blank
      @selected_id = selected_id

      foods = Food.none
      if @query.present?
        foods = Food.order(:name_ukr, :code).search_by_name_ukr(@query)
        foods = foods.from_sources(@source_codes) if @source_codes.any?
      end
      @foods = foods.limit(FOODS_LIMIT + 1).to_a
      @more = @foods.size > FOODS_LIMIT
      @foods = @foods.first(FOODS_LIMIT)

      selected = Food.find_by(id: selected_id)
      @foods.unshift(selected) if selected && @foods.exclude?(selected)
      @macros = Food.macros(@foods.map(&:id))
    end

    # Replaces the card of the changed meal; the modal closes on the successful submit
    def respond_with_meal
      day, meal = @menu_item.day, @menu_item.meal
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(helpers.meal_dom_id(@menu, day, meal),
            partial: "menus/meal", locals: { menu: @menu, day:, meal:, cells: @menu.cells(day) })
        end
        format.html { redirect_to menu_path(@menu, day:) }
      end
    end
end
