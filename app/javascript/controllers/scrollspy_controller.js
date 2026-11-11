import { Controller } from "@hotwired/stimulus"

// Highlights the nav link of the group that has reached the top of the scrolling table
// (under its sticky header) and scrolls the table, not the page, to a clicked group.
export default class extends Controller {
  static targets = [ "link", "scroller", "header" ]

  connect() {
    this.onScroll = () => {
      if (this.pinned || this.frame) return
      this.frame = requestAnimationFrame(() => {
        this.frame = null
        this.update()
      })
    }
    this.unpin = () => {
      this.pinned = false
      clearTimeout(this.unpinTimer)
    }
    this.scrollerTarget.addEventListener("scroll", this.onScroll, { passive: true })
    this.scrollerTarget.addEventListener("scrollend", this.unpin)
    this.update()
  }

  disconnect() {
    this.scrollerTarget.removeEventListener("scroll", this.onScroll)
    this.scrollerTarget.removeEventListener("scrollend", this.unpin)
    cancelAnimationFrame(this.frame)
    clearTimeout(this.unpinTimer)
  }

  // The clicked group stays active while the table scrolls to it, even if it cannot reach the top
  select(event) {
    event.preventDefault()
    this.pinned = true
    clearTimeout(this.unpinTimer)
    this.unpinTimer = setTimeout(this.unpin, 1500)
    this.activate(event.currentTarget)
    this.scrollerTarget.scrollTo({ top: this.scrollerTarget.scrollTop + this.offsetOf(event.currentTarget), behavior: "smooth" })
  }

  update() {
    const current = this.linkTargets.findLast(link => this.offsetOf(link) <= 1)
    this.activate(current ?? this.linkTargets[0])
  }

  // Distance from the bottom of the sticky header to the top of the link's group
  offsetOf(link) {
    const section = this.element.querySelector(link.hash)
    return section.getBoundingClientRect().top - this.scrollerTarget.getBoundingClientRect().top - this.headerTarget.offsetHeight
  }

  activate(link) {
    this.linkTargets.forEach(item => {
      item.classList.toggle("active", item === link)
      item.toggleAttribute("aria-current", item === link)
    })
  }
}
