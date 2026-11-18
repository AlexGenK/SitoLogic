import { Controller } from "@hotwired/stimulus"

// The menu day's nutrient panel: shows the summed nutrients of the chosen meal for the variant set its card shows
export default class extends Controller {
  static targets = [ "card", "panel" ]
  static values = { meal: Number }

  initialize() {
    this.variants = {}
  }

  select({ params: { meal } }) {
    this.mealValue = meal
  }

  // A meal card switched its set of variants
  sync({ detail: { meal, index } }) {
    this.variants[meal] = index
    if (meal === this.mealValue) this.render()
  }

  mealValueChanged() {
    this.render()
  }

  // Cards and panels come back after a Turbo Stream replaces them
  cardTargetConnected() {
    this.render()
  }

  panelTargetConnected() {
    this.render()
  }

  render() {
    const index = this.variants[this.mealValue] ?? 0
    this.cardTargets.forEach((card) => card.classList.toggle("menu-meal-selected", Number(card.dataset.meal) === this.mealValue))
    this.panelTargets.forEach((panel) => {
      panel.hidden = Number(panel.dataset.meal) !== this.mealValue
      panel.querySelectorAll("[data-variant]").forEach((set) => { set.hidden = Number(set.dataset.variant) !== index })
    })
  }
}
