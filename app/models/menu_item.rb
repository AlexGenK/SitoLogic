class MenuItem < ApplicationRecord
  belongs_to :menu
  belongs_to :food

  validates :day, :meal, :position, :variant, numericality: { only_integer: true, greater_than: 0 }
  validates :amount, numericality: { greater_than: 0 }
  validates :variant, uniqueness: { scope: [ :menu_id, :day, :meal, :position ] }
  validate :within_menu_structure

  private
    def within_menu_structure
      return unless menu

      Menu::STRUCTURE.each do |attribute, column|
        value = public_send(column)
        max = menu.public_send(attribute)
        errors.add(column, :less_than_or_equal_to, count: max) if value.is_a?(Integer) && value > max
      end
    end
end
