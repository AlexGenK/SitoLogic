class Nutrient < ApplicationRecord
  GROUPS = {
    properties: "Властивості",
    proximates: "Основні показники",
    food_labelling: "Маркування харчових продуктів",
    carbohydrate_components: "Компоненти вуглеводів",
    fat_components: "Компоненти жирів",
    vitamins: "Вітаміни",
    alt_vitamins: "Альтернативні форми вітамінів",
    vitamin_fractions: "Фракції вітамінів",
    minerals_macroelements: "Мінерали — макроелементи",
    minerals_trace_elements: "Мінерали — мікроелементи",
    amino_acids: "Амінокислоти",
    purines: "Пурини",
    organic_acids: "Органічні кислоти",
    phyto_oestrogens: "Фітоестрогени",
    flavonoids: "Флавоноїди",
    sterols: "Стерини",
    fatty_acids: "Жирні кислоти",
    undifferentiated_fatty_acids: "Недиференційовані жирні кислоти",
    user_added_nutrients: "Нутрієнти, додані користувачем"
  }.freeze
  UNITS = {
    ug: "мкг",
    mg: "мг",
    g: "г",
    kj: "кДж",
    kcal: "ккал",
    ui: "МО",
    kg_per_l: "кг/л"
  }.freeze

  has_many :food_nutrients, dependent: :restrict_with_error
  has_many :foods, through: :food_nutrients

  enum :group, GROUPS.keys.index_with(&:to_s), prefix: true, validate: { allow_nil: true }
  enum :unit, UNITS.keys.index_with(&:to_s), prefix: true, validate: { allow_nil: true }

  validates :code, presence: true, uniqueness: true

  def group_ukr
    GROUPS[group&.to_sym]
  end

  def unit_ukr
    UNITS[unit&.to_sym]
  end
end
