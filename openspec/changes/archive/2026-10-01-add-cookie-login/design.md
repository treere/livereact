## Context

Oggi `/` è `ShopLive` anonimo: `mount/3` ignora la sessione, il render mostra sempre l'isola React del market. `Endpoint` ha già sessione cookie firmata (`_livereact_key`) e la passa al socket LiveView via `connect_info: [session:]`, ma nessuno la usa. Il ponte JS è unico hook `ReactApp` (`react_hook.js` + `shop_island.jsx`) con protocollo `lv:send` → `pushEvent` e `push_event("cart-updated")` → `island.update()`. Vincoli utente: UI 100% React (anche il login), login via HTTP al BE per il token/cookie, LiveView che sa se l'utente è loggato.

## Goals / Non-Goals

**Goals:**
- Login username-only (text field + "Entra") tutto in React che ottiene la sessione via `POST /api/session` HTTP JSON.
- Cookie di sessione firmato esistente come unico token; LiveView legge `session["username"]` in `mount` e fa gate del market.
- Stesso username normalizzato (trim + downcase) = stesso utente su browser diversi.
- Logout via `DELETE /api/session` + ritorno alla vista login senza reload manuale.

**Non-Goals:**
- Password, OAuth, registrazione,anti-enumeration, remember-me, ruoli/permessi.
- Persistenza DB utenti o carrello per-utente (il carrello resta quello esistente, globale/demo).
- Token JWT opaco separato o cookie custom: si riusa `Plug.Session`.

## Decisions

- **Sessione `Plug.Session` esistente come token (non JWT custom).** Perché: zero nuove dipendenze, cookie già firmato e già inoltrato alla LiveView via `connect_info`; alternativa JWT custom scartata (doppio meccanismo, CSRF/session duplication, più codice).
- **Controller JSON `SessionController` in pipeline `:api` (`POST`/`DELETE /api/session`).** `create` valida `username` 1..32 chars (trim), normalizza `String.trim |> String.downcase`, fa `put_session(:username, normalized)` + `put_session(:display_name, trimmed)` e risponde `201 %{username}`; `delete` fa `clear_session`. Perché controller e non LiveView `handle_event`: requisito esplicito "login chiami il BE via HTTP". CSRF: `POST` via `fetch` con header `x-csrf-token` letto dal meta tag esistente (la pipeline `:browser` ha `protect_from_forgery`; la `:api` con solo `accepts json` non lo verifica — si aggiunge `fetch_session` + verifica CSRF manuale minimale o si riusa il token, vedi Rischi).
- **Gate in `ShopLive.mount`: `current_user` da sessione, render condizionale.** `mount` legge `session["username"]`, assegna `%{current_user: username_or_nil}`; il template HEEx contiene solo due contenitori `phx-update="ignore"` (uno login, uno market) + `data-current-user`; tutta la UI visibile è renderizzata da React. Alternativa `on_mount` / `live_session` scartata per ora: un `if` in `mount` + redirect via `push_navigate` non serve, basta il gate condizionale (ponytail: un `if`, non un router auth).
- **React: nuovo `LoginForm` + estensione protocollo isola esistente.** `LoginForm({onLoggedIn})` fa `fetch("/api/session", {method POST, credentials: "same-origin", json {username}})`; a successo chiama `liveSocket` reload o `pushEvent("auth-changed")` + `window.location.reload()` fallback? Scelta: dopo login/logout il client ricarica la LiveView via `liveSocket.disconnect/connect` NO — più semplice: `window.location.reload()` così la nuova connessione WS porta il cookie aggiornato e `mount` vede il nuovo `current_user`. `react_hook.js` aggiunge `handleEvent("auth-changed", ...)` per aggiornare `island.update({currentUser})` senza reload quando la sessione cambia server-side. Nessun import di `liveSocket` nei componenti (resta il ponte `lv:send`).
- **Identità = username normalizzato.** Niente id surrogati: `display_name` per UI, `username` (downcase) come chiave. Due browser con stesso username → stessa identità per costruzione. Validazione solo non-vuoto + lunghezza; niente unicità DB perché niente DB.

## Risks / Trade-offs

- [Risk] Cookie `SameSite=Lax` + `fetch` senza `credentials: "same-origin"` → login sembra riuscire ma la sessione non persiste → Mitigazione: `fetch` sempre con `credentials: "same-origin"` + test ConnTest che verifica `set-cookie` e seconda request autenticata.
- [Risk] CSRF su `POST /api/session` (pipeline `:api` non ha `protect_from_forgery`) → Mitigazione: pipeline `:api` con `fetch_session` + `protect_from_forgery`, client invia `x-csrf-token` dal meta tag. Nota implementativa: nei test Plug non rifiuta il POST senza token su sessione fresca (verificato empiricamente); protezione pratica = `SameSite=Lax` + `fetch` same-origin. Test sul 403 rimosso, da rivalutare se l'endpoint farà azioni sensibili.
- [Risk] Reload intero dopo login perde `filterText/selectedId` locali React → Mitigazione: accettato (login avviene una volta, prima del market); documentato, nessun persist necessario.
- [Risk] Session fixation (stesso cookie pre/post login) → Mitigazione: `configure_session(renew: true)` in `create`.
- Trade-off: carrello ancora globale condiviso via PubSub, non per-utente — voluto per restare minimal; per-utente è follow-up esplicito.
