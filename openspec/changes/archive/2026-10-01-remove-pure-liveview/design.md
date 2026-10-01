## Context

`ShopLive` oggi serve due pagine via `live_action`: `/` (`:index`, lista LV pura) e `/play` (`:play`, guscio+isola React). Decisione utente: pagina unica su `/` con solo guscio+isola. Stato condiviso (catalogo, carrello, PubSub) e ponte React restano invariati.

## Goals / Non-Goals

**Goals:**
- Un solo template senza branch `@live_action`, una sola route (`/`).
- Niente alias di compatibilità: `/play` sparisce, punto.

**Non-Goals:**
- Toccare `Shop`, Hook, componente React, eventi, auth.

## Decisions

- **Niente redirect, cancellazione secca di `/play`** — il toy non ha utenti né bookmark da preservare; un redirect lascerebbe una `live_action :redirect` finta da mantenere. Alternativa scartata: 302 via `push_navigate` (complessità senza beneficiari).
- **Rimuovere le `live_action` dal router** — con una sola pagina non servono più; il template non brancha su `@live_action`.
- **Header senza nav** — i link "LV pura / LV + React" non hanno più senso; resta solo titolo + totale.

## Risks / Trade-offs

- [Risk] Nessuno rilevante: cancellazione di codice morto, ponte React e stato condiviso intoccati.
