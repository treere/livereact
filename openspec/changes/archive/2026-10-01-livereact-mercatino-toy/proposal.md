## Why

Toy project per capire l'interazione bidirezionale tra una pagina Phoenix LiveView (guscio, stato condiviso sul server) e una SPA/isola React montata dentro via `phx-hook` (stato locale nel browser). Obiettivo didattico, non produttivo: vedere il ponte `push_event` / `pushEvent` funzionare in entrambe le direzioni con il minimo codice possibile.

## What Changes

- Nuova app Phoenix LiveView `livereact` con due route anonime (niente auth):
  - `/` — pagina LiveView pura (contatore + lista) come baseline senza React.
  - `/play` — pagina LiveView guscio (header/footer HEEX con carrello live) + isola React montata in `div[phx-update="ignore"]`.
- Isola React (catalogo mercatino: cards + filtro locale + selezione locale + bottone "aggiungi") che invia intenzioni a LiveView e riceve snapshot dal server.
- Ponte JS `ReactApp` Hook: monta/smonta `createRoot`, inoltra `push_event` a React e `CustomEvent` da React verso `pushEvent`.
- Catalogo hardcoded di 3-4 prodotti, carrello in `assign` + broadcast PubSub sullo stesso topic così due browser vedono lo stesso totale.

## Capabilities

### New Capabilities

- `mercatino-shop`: catalogo hardcoded + carrello LiveView condiviso (route `/` e `/play`, eventi `add-to-cart` / `remove-from-cart` / `clear-cart`, broadcast `cart-updated`).
- `react-bridge`: Hook JS + isola React con stato locale (filtro, selezione) e contratto a 4 eventi (`add-to-cart`, `remove-from-cart` in su; `items-updated`, `cart-updated` in giù).

### Modified Capabilities

- Nessuna (repo vuoto).

## Impact

- Solo codice nuovo: app Phoenix + asset React (npm `react`, `react-dom`, esbuild già di Phoenix). Nessuna API esterna, nessun DB necessario (stato in memoria, catalogo hardcoded).
- Auth esplicitamente fuori scope: tutti gli eventi si fidano, la validazione resta comunque centralizzata in `handle_event` così aggiungere auth dopo è un `if` in un punto solo.
