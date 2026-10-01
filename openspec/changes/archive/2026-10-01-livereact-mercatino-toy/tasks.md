## 1. Scaffold Phoenix

- [x] 1.1 `mix phx.new livereact --live --no-ecto --no-auth` (o equivalente) e verifica `mix phx.server` su `/`
- [x] 1.2 Aggiungi route `live "/play", ShopLive` + `live "/", ShopLive` di baseline

## 2. Mercatino LiveView (stato condiviso)

- [x] 2.1 Modulo catalogo hardcoded (3-4 prodotti) + helper totale
- [x] 2.2 `ShopLive` mount: subscribe PubSub topic `demo:lobby`, assign `items`, `cart`, `total`
- [x] 2.3 `handle_event` per `add-to-cart` / `remove-from-cart` / `clear-cart` con validazione id + broadcast `cart-updated`
- [x] 2.4 Template `/play`: header/footer HEEX carrello live + `div#react-island[phx-hook="ReactApp"][phx-update="ignore"][data-items]`

## 3. Ponte React (stato locale)

- [x] 3.1 `npm i react react-dom`, Hook `ReactApp`: `mounted` monta `createRoot`, `handleEvent` per `items-updated`/`cart-updated`, listener `lv:send` → `pushEvent`, `destroyed` fa cleanup
- [x] 3.2 Componente `ShopIsland`: cards + `filterText`/`selectedId` in `useState` locale, bottone che dispatcha `CustomEvent("lv:send", {detail: {event: "add-to-cart", payload: {id}}})`
- [x] 3.3 Verifica manuale: filtro non genera traffico WS (Network tab), click genera `add-to-cart`, totale si aggiorna senza reload

## 4. Verifica finale

- [x] 4.1 Apri due browser su `/play`: aggiungi da uno, verifica sync sull'altro
- [x] 4.2 Verifica che un re-render LV (cambio totale) non resetti filtro/selezione React
- [x] 4.3 `mix format` + nota dei limiti noti (single topic anonimo, `CustomEvent` globale) per futura auth
