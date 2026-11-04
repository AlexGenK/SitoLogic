class Nutrient < ApplicationRecord
  has_many :food_nutrients, dependent: :restrict_with_error
  has_many :foods, through: :food_nutrients

  enum :group, {
    properties: "Properties",
    proximates: "Proximates",
    food_labelling: "Food labelling",
    carbohydrate_components: "Carbohydrate components",
    fat_components: "Fat components",
    vitamins: "Vitamins",
    alt_vitamins: "Alt-vitamins",
    vitamin_fractions: "Vitamin fractions",
    minerals_macroelements: "Minerals - macroelements",
    minerals_trace_elements: "Minerals - trace elements",
    amino_acids: "Amino acids",
    purines: "Purines",
    organic_acids: "Organic acids",
    phyto_oestrogens: "Phyto-oestrogens",
    flavonoids: "Flavonoids",
    sterols: "Sterols",
    fatty_acids: "Fatty acids",
    undifferentiated_fatty_acids: "Undifferentiated fatty acids",
    user_added_nutrients: "User-added nutrients"
  }, prefix: true

  enum :unit, {
    ug: "ug", mg: "mg", g: "g", kj: "kJ", kcal: "kcal", ui: "Ui", kg_per_l: "kg/l"
  }, prefix: true

  validates :code, presence: true, uniqueness: true
end
