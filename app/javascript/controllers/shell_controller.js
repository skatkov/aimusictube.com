import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "menuButton"]

  connect() {
    this.element.classList.add("interactive")
    try {
      const theme = localStorage.getItem("appearance")
      if (theme === "dark" || theme === "light") document.documentElement.dataset.theme = theme
      document.documentElement.classList.toggle("mini-rail", localStorage.getItem("sidebar") === "collapsed")
    } catch { /* Browser storage is optional. */ }
    this.syncMenu()
  }

  menu() {
    if (matchMedia("(max-width: 1100px)").matches) {
      this.drawerTarget.showModal()
    } else {
      const collapsed = document.documentElement.classList.toggle("mini-rail")
      try { localStorage.setItem("sidebar", collapsed ? "collapsed" : "expanded") } catch { /* Keep this tab's preference. */ }
    }
    this.syncMenu()
  }

  syncMenu() {
    const drawer = matchMedia("(max-width: 1100px)").matches
    this.menuButtonTarget.setAttribute("aria-controls", drawer ? "navigation-drawer" : "navigation-rail")
    this.menuButtonTarget.setAttribute("aria-expanded", drawer ? this.drawerTarget.open : !document.documentElement.classList.contains("mini-rail"))
  }

  close() { this.drawerTarget.close() }

  backdrop(event) {
    if (event.target === this.drawerTarget && event.clientX >= this.drawerTarget.getBoundingClientRect().right) this.close()
  }

  theme() {
    const root = document.documentElement
    const dark = root.dataset.theme ? root.dataset.theme === "dark" : matchMedia("(prefers-color-scheme: dark)").matches
    root.dataset.theme = dark ? "light" : "dark"
    try { localStorage.setItem("appearance", root.dataset.theme) } catch { /* Keep this tab's preference. */ }
  }
}
