import { Controller } from "@hotwired/stimulus"

// Submits the search form while typing: once the query has minLength characters, or when it is cleared
export default class extends Controller {
  static targets = [ "query", "reset", "source" ]
  static values = { minLength: { type: Number, default: 3 }, delay: { type: Number, default: 300 } }

  connect() {
    this.lastQuery = this.query
  }

  disconnect() {
    this.cancel()
  }

  search() {
    this.cancel()
    this.timeout = setTimeout(() => this.submit(), this.delayValue)
  }

  cancel() {
    clearTimeout(this.timeout)
  }

  submit() {
    const query = this.query
    if (query === this.lastQuery) return
    if (query.length > 0 && query.length < this.minLengthValue) return

    this.lastQuery = query
    if (this.hasResetTarget) this.resetTarget.hidden = query === "" && !this.sourceTargets.some((source) => source.checked)
    this.element.requestSubmit()
  }

  get query() {
    return this.queryTarget.value.trim()
  }
}
