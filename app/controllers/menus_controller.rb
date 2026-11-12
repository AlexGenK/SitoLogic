class MenusController < ApplicationController
  before_action :set_menu, only: [ :show, :edit, :update ]

  def index
    @menus = Menu.order(:code)
  end

  def show
    @day = params.fetch(:day, 1).to_i.clamp(1, @menu.days_count)
    @cells = @menu.cells(@day)
  end

  def new
    @menu = Menu.new
  end

  def create
    @menu = Menu.new(menu_params)
    if @menu.save
      redirect_to @menu, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @menu.update(menu_params)
      redirect_to @menu, notice: t(".saved")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_menu
      @menu = Menu.find(params[:id])
    end

    def menu_params
      params.expect(menu: [ :code, :name, :days_count, :meals_per_day, :items_per_meal, :variants_per_item ])
    end
end
