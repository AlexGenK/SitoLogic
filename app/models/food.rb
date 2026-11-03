class Food < ApplicationRecord
  belongs_to :source, foreign_key: :source_code, primary_key: :code
  belongs_to :group, primary_key: [ :group_type, :code ], foreign_key: [ :group_type, :group_code ], optional: true

  scope :search_by_name_ukr, ->(query) { where("instr(unicode_lower(name_ukr), ?) > 0", query.downcase) }
  scope :from_sources, ->(codes) { where(source_code: codes) }

  normalizes :code, :name_ukr, :group_code, with: ->(value) { value.strip.presence }

  validates :code, presence: true, uniqueness: { scope: :source_code }
  validates :name_ukr, presence: true
  validate :group_allowed_by_source

  def available_groups
    source.groups.order(:code)
  end

  private
    def group_allowed_by_source
      return if group_code.nil? || source.nil?

      errors.add(:group_code, :inclusion) unless source.groups.exists?(code: group_code)
    end
end
