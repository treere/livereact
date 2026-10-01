## 1. BE sessione cookie-based

- [x] 1.1 Creare `LivereactWeb.SessionController` con `create` (valida trim 1..32, normalizza downcase, `configure_session(renew: true)` + `put_session`, `201 %{username, display_name}` / `422`) e `delete` (`clear_session`, `200 %{ok: true}`)
- [x] 1.2 Aggiungere scope `/api` pipeline `:api` in `Router` con `post "/session"` e `delete "/session"` + gestione CSRF (`x-csrf-token` dal meta tag)
- [x] 1.3 Verificare con `mix test` ConnTest: `201` + `set-cookie`, `422` vuoto/troppo-lungo, `DELETE` pulisce, normalizzazione `" Mario "` → `mario`

## 2. Gate LiveView

- [x] 2.1 In `ShopLive.mount/3` leggere `session["username"]`/`display_name`, assegnare `current_user`; render condizionale con soli contenitori `phx-update="ignore"` + `data-current-user`
- [x] 2.2 Negare `add-to-cart`/`remove-from-cart`/`clear-cart` quando `current_user` è `nil` (nessun assign/broadcast)
- [x] 2.3 Verificare con `ShopLiveTest`: anonimo vede gate login, loggato (sessione stub) vede market

## 3. UI 100% React

- [x] 3.1 Creare componente `LoginForm` React (input + bottone "Entra", `fetch` JSON `credentials: "same-origin"`, gestione errori `422`) e bottone "Esci" (`DELETE /api/session`)
- [x] 3.2 Estendere `react_hook.js`/`shop_island.jsx`: montare `LoginForm` se `currentUser` assente altrimenti market, reload/riconnessione dopo login/logout, evento `auth-changed`
- [x] 3.3 Verifica manuale: `mix phx.server` — anonimo vede solo login, login `mario` → market, secondo browser stesso username = stesso utente, logout → login

## 4. Pulizia e regressione

- [x] 4.1 `mix format`, `mix test`, `mix assets.build` (se presente) verdi
- [x] 4.2 Aggiornare/estendere `shop_live_test.exs` esistente per il gate auth
