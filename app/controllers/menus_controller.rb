class MenusController < ApplicationController
  before_action :set_menu, only: [ :show, :edit, :update, :report, :grid ]

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

  def report
    @rows = helpers.menu_report_rows(@menu)
    @nutrient_groups = helpers.menu_report_nutrient_groups(@menu)
    @foods = helpers.menu_report_foods(@menu)

    respond_to do |format|
      format.html
      format.pdf do
        send_data report_pdf.render, filename: "menu-#{@menu.code}-report.pdf", type: :pdf, disposition: "attachment"
      end
    end
  end

  def grid
  end

  private
    def set_menu
      @menu = Menu.find(params[:id])
    end

    def menu_params
      params.expect(menu: [ :code, :name, :days_count, :meals_per_day, :items_per_meal, :variants_per_item ])
    end

    def report_pdf
      MenuReportPdf.new(
        title: t("menus.report.title"),
        rows: @rows.map { |key, value| [ t("menus.report.#{key}"), value ] },
        nutrients: {
          title: t("menus.report.nutrients_title"),
          header: [ t("foods.nutrients.nutrient"), t("menus.report.nutrients_unit_short"),
                    *%w[total per_day per_meal per_dish].map { t("menus.report.nutrients_#{it}") } ],
          groups: helpers.menu_report_nutrient_text(@nutrient_groups)
        },
        foods: {
          title: t("menus.report.foods_title"),
          header: %w[source code amount share name].map { t("menus.report.foods_#{it}") },
          rows: @foods.map { |food, amount, share| [ food.source_code, food.code, helpers.grams(amount), helpers.percent_share(share), food.name_ukr ] },
          total: [ t("menus.report.foods_total"), "", helpers.grams(@menu.total_amount), helpers.percent_share(100), "" ]
        }
      )
    end
end
