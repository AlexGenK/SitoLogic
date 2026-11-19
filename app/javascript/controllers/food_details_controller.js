import { Controller } from "@hotwired/stimulus"

// Loads the nutrient panel of the food chosen in the menu item picker and scales its portion column to the weight
export default class extends Controller {
  static targets = [ "frame", "amount", "portion", "portionHeader" ]
  static values = { url: String }

  load(event) {
    const input = event.target
    if (input.name !== "menu_item[food_id]" || !input.checked) return

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("food_id", input.value)
    this.frameTarget.src = url.toString()
  }

  // A newly loaded panel gets the current weight
  portionHeaderTargetConnected() {
    this.scale()
  }

  scale() {
    if (!this.hasAmountTarget) return

    const amount = parseFloat(this.amountTarget.value)
    const known = amount > 0
    if (this.hasPortionHeaderTarget) {
      const header = this.portionHeaderTarget
      header.textContent = known ? header.dataset.template.replace("%{amount}", this.formatWeight(amount)) : header.dataset.empty
    }
    this.portionTargets.forEach((cell) => {
      cell.textContent = known ? this.formatSum(parseFloat(cell.dataset.per100) * amount / 100) : "—"
    })
  }

  // Weight with at most one decimal, as in the menu: 150 · 150,5
  formatWeight(value) {
    return value.toLocaleString("uk-UA", { maximumFractionDigits: 1 })
  }

  // 3 significant digits, as the menu's nutrient sums: 160 · 20,7 · 0,39
  formatSum(value) {
    return Number(value.toPrecision(3)).toLocaleString("uk-UA", { maximumFractionDigits: 10 })
  }
}
