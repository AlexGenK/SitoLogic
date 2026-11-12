import { Controller } from "@hotwired/stimulus"

// Switches a meal card's totals between sets of dish variants and highlights the foods counted in the shown set
export default class extends Controller {
  static targets = [ "set", "label", "chip" ]
  static values = { index: Number, label: String }

  previous() {
    this.indexValue = (this.indexValue - 1 + this.setTargets.length) % this.setTargets.length
  }

  next() {
    this.indexValue = (this.indexValue + 1) % this.setTargets.length
  }

  indexValueChanged() {
    const set = this.setTargets[this.indexValue]
    if (!set) return

    this.setTargets.forEach((element, index) => { element.hidden = index !== this.indexValue })
    const ids = JSON.parse(set.dataset.items)
    this.chipTargets.forEach((chip) => chip.classList.toggle("menu-variant-chosen", ids.includes(Number(chip.dataset.itemId))))
    if (this.hasLabelTarget) this.labelTarget.textContent = this.labelValue.replace("%{number}", this.indexValue + 1)
  }
}
