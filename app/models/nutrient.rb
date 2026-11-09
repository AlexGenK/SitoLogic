class Nutrient < ApplicationRecord
  GROUPS = %w[
    properties proximates food_labelling carbohydrate_components fat_components
    vitamins alt_vitamins vitamin_fractions minerals_macroelements minerals_trace_elements
    amino_acids purines organic_acids phyto_oestrogens flavonoids sterols
    fatty_acids undifferentiated_fatty_acids user_added_nutrients
  ].freeze
  UNITS = %w[ug mg g kj kcal ui kg_per_l].freeze

  has_many :food_nutrients, dependent: :restrict_with_error
  has_many :foods, through: :food_nutrients

  enum :group, GROUPS.index_by(&:itself), prefix: true, validate: { allow_nil: true }
  enum :unit, UNITS.index_by(&:itself), prefix: true, validate: { allow_nil: true }

  validates :code, presence: true, uniqueness: true
end
