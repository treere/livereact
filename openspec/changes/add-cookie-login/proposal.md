## Why

Il mercatino (`ShopLive` + isola React) oggi è anonimo e senza login: chiunque apre `/` accede al market senza identità. Serve un login cookie-based minimalista (solo username) per identificare l'utente, condividere l'identità tra browser diversi con lo stesso username, e far sapere alla LiveView se l'utente è loggato.

## What Changes

- Nuova pagina/Sezione login interamente in React (text field username + bottone "Entra") che chiama il BE via HTTP `POST /api/session` per ottenere il token/sessione cookie-based.
- Nuovo endpoint HTTP JSON `POST /api/session` (body `%{username}`) che valida lo username non vuoto, crea/ritrova l'utente per username normalizzato e imposta il cookie di sessione firmato (`_livereact_key` esistente, via `put_session`).
- Nuovo endpoint `DELETE /api/session` (logout) che pulisce la sessione.
- `ShopLive.mount/3` legge `session["username"]` (passata via `connect_info` già configurato in `Endpoint`) e assegna `current_user`; se assente mostra il login React invece del market.
- Il market resta accessibile solo da loggati; due browser con stesso username risultano lo stesso utente (identità = username normalizzato, nessun password/token opaco per-browser).
- Interfaccia 100% React: anche login/logout vivono nell'isola React montata via `phx-hook="ReactApp"`; la LiveView passa `current_user` come `data-` attribute / `push_event`, mai HTML HEEx per il form.

## Capabilities

### New Capabilities
- `cookie-auth`: login/logout cookie-based username-only via HTTP JSON + sessione LiveView (`current_user`, gate del market).
- `login-gate`: gating del market — utenti anonimi vedono solo il login React, utenti loggati vedono il market.

### Modified Capabilities
- Nessuna (nessuna spec esistente in `openspec/specs/`).

## Impact

- Affected code: `LivereactWeb.Router` (nuove route `/api/session`), nuovo controller JSON `SessionController`, `ShopLive` (mount + render gate), `assets/js/*` (componente `LoginForm` React + hook update `auth-changed`), `Endpoint` (riuso `@session_options` esistenti, nessuna modifica attesa).
- APIs: `POST /api/session`, `DELETE /api/session` (JSON, pipeline `:api`).
- Systems/Deps: nessuna nuova dipendenza; riusa `Plug.Session` cookie firmato, `Phoenix.LiveView connect_info: [session:]`, `fetch` browser con `credentials: "same-origin"` + CSRF esistente.
