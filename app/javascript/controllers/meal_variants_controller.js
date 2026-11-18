import { Controller } from "@hotwired/stimulus"

// Switches a meal card's totals between sets of dish variants and highlights the foods counted in the shown set
export default class extends Controller {
  static targets = [ "set", "label", "chip" ]
  static values = { index: Number, label: String }

  previous() {
    this.userSwitched = true
    this.indexValue = (this.indexValue - 1 + this.setTargets.length) % this.setTargets.length
  }

  next() {
    this.userSwitched = true
    this.indexValue = (this.indexValue + 1) % this.setTargets.length
  }

  indexValueChanged() {
    const set = this.setTargets[this.indexValue]
    if (!set) return

    this.setTargets.forEach((element, index) => { element.hidden = index !== this.indexValue })
    const ids = JSON.parse(set.dataset.items)
    this.chipTargets.forEach((chip) => {
      const chosen = ids.includes(Number(chip.dataset.itemId))
      chip.classList.toggle("menu-variant-chosen", chosen)
      // Bring the counted variant into view inside its scrolling strip; not on first render, so the page doesn't jump
      if (chosen && this.userSwitched) chip.scrollIntoView({ block: "nearest", inline: "nearest", behavior: "smooth" })
    })
    if (this.hasLabelTarget) this.labelTarget.textContent = this.labelValue.replace("%{number}", this.indexValue + 1)
  }
}
