## Context

Repo vuoto, Elixir 1.19 + Node 24 disponibili. Toy didattico: guscio LiveView + isola React, ognuno col suo stato (decisione presa in explore), niente auth (rimandata). Riferimento inverso: thread Reddit "rendering LiveView from existing React SPA" (migrazione route-by-route) — noi facciamo l'opposto: React dentro LiveView.

## Goals / Non-Goals

**Goals:**
- Mostrare il ponte bidirezionale minimo: `push_event` (LV→React) e `pushEvent` (React→LV) tramite Hook.
- Separazione stato pulita: LV = catalogo + carrello condivisi; React = filtro + selezione locali.
- Effetto multi-browser gratis via PubSub su singolo topic.

**Non-Goals:**
- Auth/autorizzazione, DB persistente, design system, test esaustivi, produzione.
- Input controllati da LV, sync ad alta frequenza, SSR React.

## Decisions

- **Una sola LiveView con due `live_action` (`/` e `/play`) invece di due LiveView** — meno file, stesso router dimostra LV pura vs LV+React. Alternativa scartata: due moduli separati (più boilerplate per zero lezione in più).
- **Hook unico `ReactApp`, ponte via `CustomEvent("lv:send")`** — React resta framework-agnostic (non importa `liveSocket` nei componenti), l'Hook fa da traduttore. Alternativa scartata: passare callback via props dal Hook con `createRoot.render(<App pushEvent={...} />)` — più elegante ma accoppia React a LV; il `CustomEvent` è più grezzo ma mostra il confine esplicito.
- **Stato effimero, niente Ecto/DB** — catalogo hardcoded in modulo Elixir, carrello in `assign` + `Phoenix.PubSub` broadcast. Alternativa scartata: Ecto SQLite — zero valore didattico sul ponte, solo setup.
- **Solo 4 eventi JSON piatti** (`add-to-cart {id}`, `remove-from-cart {id}`, `clear-cart {}`, `cart-updated {cart, total}`, `items-updated {items}`) — tutto serializzabile, niente struct/atom al confine. Validazione solo in `handle_event` così aggiungere auth dopo è un `if` in un punto.
- **`phx-update="ignore"` sul contenitore + `data-items` per snapshot iniziale** — evita che LV smonti la root React a ogni patch; lo snapshot iniziale arriva via data-attribute, gli update via `handleEvent`.

## Risks / Trade-offs

- [Risk] Doppio stato divergente (cart sia in `assign` che in `useState`) → Mitigazione: regola "una fonte per pezzo" — cart vive solo in LV, React lo mostra ma non lo modifica localmente.
- [Risk] Remount/leak (`createRoot` + listener duplicati) → Mitigazione: `mounted` monta una volta, `destroyed` fa `unmount` + `removeEventListener`.
- [Risk] Tentazione di input controllato da LV (lag per round-trip) → Mitigazione: filtro resta `useState` locale, mai mandato al server; si manda solo l'intenzione discreta (click).
- [Trade-off] `CustomEvent` globale è naive (collisioni se più isole) → accettato per toy; upgrade path: scope per `el.id` o callback props se servono N isole.
