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
  # Codes of the macronutrients shown in menus, in order of preference:
  # carbohydrates fall back from 105 (available) to 156 (by difference)
  MACROS = { energy: %w[107], protein: %w[103], fat: %w[104], carbs: %w[105 156] }.freeze

  has_many :food_nutrients, dependent: :restrict_with_error
  has_many :foods, through: :food_nutrients

  enum :group, GROUPS.keys.index_with(&:to_s), prefix: true, validate: { allow_nil: true }
  enum :unit, UNITS.keys.index_with(&:to_s), prefix: true, validate: { allow_nil: true }

  normalizes :med_name_ukr, :long_name_ukr, with: ->(value) { value.strip.presence }

  validates :code, presence: true, uniqueness: true
  # Not checked by import:nutrients (context :import), which writes English fields only
  validates :med_name_ukr, :long_name_ukr, presence: true, on: [ :create, :update ]

  def group_ukr
    GROUPS[group&.to_sym]
  end

  def unit_ukr
    UNITS[unit&.to_sym]
  end

  def display_name
    long_name_ukr.presence || long_name_en
  end
end
