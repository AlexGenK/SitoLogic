import { Controller } from "@hotwired/stimulus"

// Weights of protein, fat and carbohydrates in a split: kcal per gram for energy, 1 for weight
const SPLIT_FACTORS = {
  energy: { protein: 4, fat: 9, carbs: 4 },
  weight: { protein: 1, fat: 1, carbs: 1 }
}

// Live portion summary in the menu item form: energy and macros of the chosen food for the entered weight
export default class extends Controller {
  static targets = [ "amount", "summary", "share", "segment" ]
  static values = { template: String, shareTemplates: Object }

  connect() {
    this.update()
  }

  update() {
    const food = this.element.querySelector("input[name='menu_item[food_id]']:checked")
    const amount = parseFloat(this.amountTarget.value)
    if (!food || !(amount > 0)) return this.render("", {})

    const portion = (key) => {
      const value = parseFloat(food.dataset[key])
      return Number.isNaN(value) ? null : value * amount / 100
    }
    const values = { energy: portion("energy"), protein: portion("protein"), fat: portion("fat"), carbs: portion("carbs") }
    const text = this.templateValue.replace(/%\{(\w+)\}/g, (_, key) => this.format(values[key]))
    const shares = Object.fromEntries(Object.entries(SPLIT_FACTORS).map(([ split, factors ]) => [ split, this.shares(values, factors) ]))
    this.render(text, shares)
  }

  // Percent shares of the macros weighted by factors, or null when there is nothing to split
  shares(values, factors) {
    const parts = Object.fromEntries(Object.entries(factors).map(([ key, factor ]) => [ key, (values[key] ?? 0) * factor ]))
    const total = Object.values(parts).reduce((sum, part) => sum + part, 0)
    return total > 0 ? Object.fromEntries(Object.entries(parts).map(([ key, part ]) => [ key, part / total * 100 ])) : null
  }

  render(text, shares) {
    this.summaryTarget.textContent = text
    for (const segment of this.segmentTargets) {
      const split = shares[segment.dataset.split]
      segment.style.width = split ? `${split[segment.dataset.key]}%` : "0"
    }
    for (const share of this.shareTargets) {
      const split = shares[share.dataset.split]
      share.textContent = split
        ? this.shareTemplatesValue[share.dataset.split].replace(/%\{(\w+)\}/g, (_, key) => Math.round(split[key]))
        : ""
    }
  }

  format(value) {
    return value == null ? "—" : value.toLocaleString("uk-UA", { maximumFractionDigits: 1 })
  }
}
