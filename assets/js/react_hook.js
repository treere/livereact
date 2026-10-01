// Ponte LiveView <-> React (unico Hook, cfr. design.md).
// React non importa mai liveSocket: parla solo via CustomEvent("lv:send"),
// l'Hook traduce da/per pushEvent/handleEvent.
import {mountShopIsland} from "./shop_island.jsx"

export const ReactApp = {
  mounted() {
    let items = []
    try {
      items = JSON.parse(this.el.dataset.items || "[]")
    } catch (_e) {
      items = []
    }

    this._island = mountShopIsland(this.el, {
      items,
      cart: [],
      total: 0,
      currentUser: this.el.dataset.currentUser || "",
      displayName: this.el.dataset.displayName || "",
      onSend: (event, payload) =>
        window.dispatchEvent(new CustomEvent("lv:send", {detail: {event, payload}}))
    })

    this._onLvSend = (e) => {
      const {event, payload} = (e && e.detail) || {}
      if (event) this.pushEvent(event, payload || {})
    }
    window.addEventListener("lv:send", this._onLvSend)

    this.handleEvent("cart-updated", ({cart, total}) => {
      if (this._island) this._island.update({cart, total})
    })
    this.handleEvent("items-updated", ({items}) => {
      if (this._island) this._island.update({items})
    })
    this.handleEvent("auth-changed", ({current_user, display_name}) => {
      if (this._island)
        this._island.update({currentUser: current_user || "", displayName: display_name || ""})
    })
  },

  destroyed() {
    window.removeEventListener("lv:send", this._onLvSend)
    if (this._island) this._island.unmount()
    this._island = null
  }
}
