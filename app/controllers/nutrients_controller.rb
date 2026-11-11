class NutrientsController < ApplicationController
  OTHER_GROUP = "other"

  before_action :set_nutrient, only: [ :show, :edit, :update ]

  def index
    @group_counts = Nutrient.group(:group).count.transform_keys { it || OTHER_GROUP }
    @groups = (Nutrient.groups.keys + [ OTHER_GROUP ]) & @group_counts.keys
    @group = @groups.include?(params[:group]) ? params[:group] : @groups.first
    @nutrients = @group ? Nutrient.where(group: (@group unless @group == OTHER_GROUP)).order(:id) : Nutrient.none
  end

  def show
  end

  def edit
  end

  def update
    if @nutrient.update(nutrient_params)
      redirect_to nutrient_path(@nutrient), notice: t(".saved")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_nutrient
      @nutrient = Nutrient.find(params[:id])
      @group = @nutrient.group || OTHER_GROUP
    end

    def nutrient_params
      params.expect(nutrient: [ :med_name_ukr, :long_name_ukr ])
    end
end
