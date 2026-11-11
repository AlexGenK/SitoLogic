class NutrientsController < ApplicationController
  OTHER_GROUP = "other"

  def index
    @group_counts = Nutrient.group(:group).count.transform_keys { it || OTHER_GROUP }
    @groups = (Nutrient.groups.keys + [ OTHER_GROUP ]) & @group_counts.keys
    @group = @groups.include?(params[:group]) ? params[:group] : @groups.first
    @nutrients = @group ? Nutrient.where(group: (@group unless @group == OTHER_GROUP)).order(:id) : Nutrient.none
  end

  def show
    @nutrient = Nutrient.find(params[:id])
    @group = @nutrient.group || OTHER_GROUP
  end
end
