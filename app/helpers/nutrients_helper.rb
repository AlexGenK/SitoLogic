module NutrientsHelper
  def nutrient_group_name(group)
    return t("nutrients.index.other_group") if group == NutrientsController::OTHER_GROUP

    Nutrient::GROUPS[group.to_sym]
  end
end
