## Why

Il confronto baseline (pagina LiveView pura vs guscio+isola) ha esaurito il suo scopo didattico: il branch `:index` è codice morto che raddoppia i rami del template e le route da mantenere. Il toy diventa una pagina unica React+LiveView.

## What Changes

- **BREAKING**: la route `/play` viene rimossa del tutto (chi la visita prende 404).
- `ShopLive` serve solo `/` con guscio LiveView (header/footer carrello) + isola React; rimosso il branch `@live_action == :play` e la lista baseline con bottoni `phx-click`.
- Rimosse le `live_action` e i link di navigazione "LV pura / LV + React" dall'header.
- Test aggiornati: `/` rende guscio+isola.
- Ponte React/Hook, catalogo e carrello invariati.

## Capabilities

### New Capabilities

- `single-page-shell`: pagina unica su `/` che combina guscio LiveView e isola React, con redirect da `/play`.

### Modified Capabilities

- Nessuna (nessuna spec in `openspec/specs/`).

## Impact

- `lib/livereact_web/router.ex`, `lib/livereact_web/live/shop_live.ex`, `test/livereact_web/live/shop_live_test.exs`.
- Nessun impatto su `Shop`, Hook React, assets, auth (già fuori scope).
