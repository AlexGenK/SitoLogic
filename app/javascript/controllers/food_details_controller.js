import { Controller } from "@hotwired/stimulus"

// Loads the nutrient panel of the food chosen in the menu item picker
export default class extends Controller {
  static targets = [ "frame" ]
  static values = { url: String }

  load(event) {
    const input = event.target
    if (input.name !== "menu_item[food_id]" || !input.checked) return

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("food_id", input.value)
    this.frameTarget.src = url.toString()
  }
}
