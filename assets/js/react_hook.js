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
  },

  destroyed() {
    window.removeEventListener("lv:send", this._onLvSend)
    if (this._island) this._island.unmount()
    this._island = null
  }
}
