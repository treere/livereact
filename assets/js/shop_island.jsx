import React, {useState} from "react"
import {createRoot} from "react-dom/client"

function send(event, payload) {
  window.dispatchEvent(new CustomEvent("lv:send", {detail: {event, payload}}))
}

function ShopIsland({items, cart, total, onSend}) {
  // Stato locale: non lascia MAI il browser (nessun evento WS qui)
  const [filterText, setFilterText] = useState("")
  const [selectedId, setSelectedId] = useState(null)

  const emit = onSend || send
  const q = filterText.toLowerCase()
  const visible = (items || []).filter((i) => i.name.toLowerCase().includes(q))

  return (
    <div>
      <div className="flex items-center gap-2">
        <input
          value={filterText}
          onChange={(e) => setFilterText(e.target.value)}
          placeholder="Filtra…"
          className="rounded border px-2 py-1 text-sm"
        />
        <span className="text-sm opacity-60">totale live: {total}€</span>
      </div>
      <ul className="mt-3 grid gap-2">
        {visible.map((item) => (
          <li
            key={item.id}
            onClick={() => setSelectedId(item.id)}
            className={
              "flex items-center justify-between rounded border p-2 cursor-pointer" +
              (selectedId === item.id ? " border-black border-2" : "")
            }
          >
            <span>
              {item.name} — {item.price}€
            </span>
            <button
              onClick={(e) => {
                e.stopPropagation()
                emit("add-to-cart", {id: item.id})
              }}
              className="rounded bg-black px-3 py-1 text-white text-sm"
            >
              Aggiungi
            </button>
          </li>
        ))}
      </ul>
      {visible.length === 0 && <p className="mt-2 text-sm opacity-60">Niente con questo filtro.</p>}
    </div>
  )
}

// Monta UNA volta sola; update() ri-renderizza la stessa root
// così filterText/selectedId sopravvivono ai push dal server.
export function mountShopIsland(el, initial) {
  const root = createRoot(el)
  let state = initial

  function render() {
    root.render(<ShopIsland {...state} />)
  }
  render()

  return {
    update(patch) {
      state = {...state, ...patch}
      render()
    },
    unmount() {
      root.unmount()
    }
  }
}

export default ShopIsland
