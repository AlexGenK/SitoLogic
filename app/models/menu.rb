class Menu < ApplicationRecord
  STRUCTURE = {
    days_count: :day,
    meals_per_day: :meal,
    items_per_meal: :position,
    variants_per_item: :variant
  }.freeze

  has_many :menu_items, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates(*STRUCTURE.keys, numericality: { only_integer: true, greater_than: 0 })
  validate :structure_fits_items, on: :update

  private
    # Не дає зменшити сітку, якщо заповнені клітинки опиняться за її межами.
    def structure_fits_items
      STRUCTURE.each do |attribute, column|
        max = public_send(attribute)
        next unless max.is_a?(Integer) && will_save_change_to_attribute?(attribute)

        if menu_items.where(column => (max + 1)..).exists?
          errors.add(attribute, :items_outside)
        end
      end
    end
end
