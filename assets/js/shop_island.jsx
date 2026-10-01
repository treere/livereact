import React, {useState} from "react"
import {createRoot} from "react-dom/client"

function send(event, payload) {
  window.dispatchEvent(new CustomEvent("lv:send", {detail: {event, payload}}))
}

function csrfToken() {
  return document.querySelector("meta[name='csrf-token']")?.getAttribute("content") || ""
}

async function apiLogin(username) {
  const res = await fetch("/api/session", {
    method: "POST",
    credentials: "same-origin",
    headers: {"content-type": "application/json", "x-csrf-token": csrfToken()},
    body: JSON.stringify({username})
  })
  if (res.status === 201) return {ok: true, data: await res.json()}
  const data = await res.json().catch(() => ({}))
  return {ok: false, error: data.error || "login fallito"}
}

async function apiLogout() {
  await fetch("/api/session", {
    method: "DELETE",
    credentials: "same-origin",
    headers: {"x-csrf-token": csrfToken()}
  }).catch(() => {})
  window.location.reload()
}

function LoginForm() {
  const [username, setUsername] = useState("")
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)

  async function submit(e) {
    e?.preventDefault()
    setError(null)
    if (!username.trim()) {
      setError("username richiesto")
      return
    }
    setBusy(true)
    try {
      const r = await apiLogin(username.trim())
      if (r.ok) window.location.reload()
      else setError(r.error)
    } catch (_e) {
      setError("errore rete")
    } finally {
      setBusy(false)
    }
  }

  return (
    <form onSubmit={submit}>
      <div className="flex items-center gap-2">
        <input
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="username"
          aria-label="username"
          className="rounded border px-2 py-1 text-sm"
        />
        <button
          type="submit"
          disabled={busy}
          className="rounded bg-black px-3 py-1 text-white text-sm disabled:opacity-50"
        >
          Entra
        </button>
      </div>
      {error && <p className="mt-2 text-sm text-red-600">{error}</p>}
    </form>
  )
}

function ShopIsland({items, cart, total, currentUser, displayName, onSend}) {
  // Stato locale: non lascia MAI il browser (nessun evento WS qui)
  const [filterText, setFilterText] = useState("")
  const [selectedId, setSelectedId] = useState(null)

  if (!currentUser) return <LoginForm />

  const emit = onSend || send
  const q = filterText.toLowerCase()
  const visible = (items || []).filter((i) => i.name.toLowerCase().includes(q))

  return (
    <div>
      <div className="flex items-center justify-between gap-2">
        <span className="text-sm opacity-70">Ciao {displayName || currentUser}</span>
        <button onClick={apiLogout} className="text-sm underline">
          Esci
        </button>
      </div>
      <div className="mt-2 flex items-center gap-2">
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
