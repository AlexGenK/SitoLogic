import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

export default class extends Controller {
  connect() {
    Toast.getOrCreateInstance(this.element).show()
  }
}
