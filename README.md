# Livereact — mercatino toy LiveView + React

Pagina unica (`/`) con guscio Phoenix LiveView e isola React montata via hook.
Stato condiviso (catalogo, carrello) sul server con broadcast PubSub; stato
locale (filtro, selezione) solo in React, mai sincronizzato.

Login username-only via cookie firmato: gli anonimi vedono solo il form login
(React), i loggati vedono il market. Eventi market da anonimi ignorati.

## Route

* `GET /` — guscio LiveView + isola React (gate login)
* `POST /api/session` — login `{"username": "..."}` → `201` / `422`
* `DELETE /api/session` — logout → `200`

## Sviluppo

* Setup: `mix setup`
* Server: `mix phx.server` → http://localhost:4000
* Test: `mix test` · Check completo: `mix precommit`

## Struttura

* `lib/livereact_web/live/shop_live.ex` — guscio + gate auth + eventi carrello
* `lib/livereact_web/controllers/session_controller.ex` — login/logout JSON
* `assets/js/react_hook.js` — hook `ReactApp` (mount/bridge/cleanup)
* `assets/js/shop_island.jsx` — `ShopIsland` + `LoginForm`
* `openspec/specs/` — requisiti (`mercatino-shop`, `react-bridge`,
  `single-page-shell`, `cookie-auth`, `login-gate`)
