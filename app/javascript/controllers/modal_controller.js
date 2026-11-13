import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// The shared modal: links with data-turbo-frame="modal" load content into its frame and open it;
// a form marked data-modal-close closes it after a successful submit
export default class extends Controller {
  static targets = [ "frame", "dialog" ]

  connect() {
    this.modal = Modal.getOrCreateInstance(this.element)
    this.element.addEventListener("shown.bs.modal", this.focus)
    this.element.addEventListener("hidden.bs.modal", this.clear)
  }

  disconnect() {
    this.element.removeEventListener("shown.bs.modal", this.focus)
    this.element.removeEventListener("hidden.bs.modal", this.clear)
    this.modal.dispose()
  }

  open(event) {
    if (event.target !== this.frameTarget) return

    // The content picks the dialog size with data-modal-size on its root (lg by default)
    const size = this.frameTarget.querySelector("[data-modal-size]")?.dataset.modalSize || "lg"
    this.dialogTarget.classList.remove("modal-lg", "modal-xl")
    this.dialogTarget.classList.add(`modal-${size}`)
    this.modal.show()
  }

  close(event) {
    if (event.detail.success && "modalClose" in event.target.dataset) this.modal.hide()
  }

  focus = () => {
    this.element.querySelector("[autofocus]")?.focus()
  }

  // Empty the frame so the same link loads fresh content next time
  clear = () => {
    this.frameTarget.removeAttribute("src")
    this.frameTarget.replaceChildren()
  }
}
