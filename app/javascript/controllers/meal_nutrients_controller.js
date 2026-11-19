import { Controller } from "@hotwired/stimulus"

// The menu day's nutrients: the panel of the chosen meal for the variant set its card shows, and the day table
// that Rails renders for the sets all cards show
export default class extends Controller {
  static targets = [ "card", "panel", "dayFrame" ]
  static values = { meal: Number, dayUrl: String }

  initialize() {
    this.variants = {}
  }

  // Target callbacks run before connect, so panels connecting later came from a Turbo Stream
  connect() {
    this.ready = true
  }

  disconnect() {
    clearTimeout(this.dayTimeout)
  }

  select({ params: { meal } }) {
    this.mealValue = meal
  }

  // A meal card switched its set of variants
  sync({ detail: { meal, index } }) {
    const changed = meal in this.variants && this.variants[meal] !== index
    this.variants[meal] = index
    if (meal === this.mealValue) this.render()
    if (changed) this.reloadDay()
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
    // A meal's foods changed in the picker: its card and panel were replaced
    if (this.ready) this.reloadDay()
  }

  render() {
    const index = this.variants[this.mealValue] ?? 0
    this.cardTargets.forEach((card) => card.classList.toggle("menu-meal-selected", Number(card.dataset.meal) === this.mealValue))
    this.panelTargets.forEach((panel) => {
      panel.hidden = Number(panel.dataset.meal) !== this.mealValue
      panel.querySelectorAll("[data-variant]").forEach((set) => { set.hidden = Number(set.dataset.variant) !== index })
    })
  }

  // Ask Rails for the day table with each meal's shown set; waits a moment so quick clicks make one request
  reloadDay() {
    clearTimeout(this.dayTimeout)
    this.dayTimeout = setTimeout(() => {
      if (!this.hasDayFrameTarget) return

      const url = new URL(this.dayUrlValue, window.location.origin)
      this.cardTargets.forEach((card) => url.searchParams.append("variants[]", (this.variants[card.dataset.meal] ?? 0) + 1))
      const frame = this.dayFrameTarget
      if (frame.src === url.toString()) frame.reload()
      else frame.src = url.toString()
    }, 250)
  }
}
