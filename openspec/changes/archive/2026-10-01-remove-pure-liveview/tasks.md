## 1. Router e LiveView

- [x] 1.1 Router: solo `live "/", ShopLive` (via `/play`, via `live_action`)
- [x] 1.2 `ShopLive`: render senza branch `@live_action` (solo guscio+isola, header senza nav)

## 2. Test e verifica

- [x] 2.1 Aggiorna `shop_live_test.exs`: `/` rende guscio+isola, `/play` dà 404
- [x] 2.2 `mix format`, `mix test`, boot e controllo visivo di `/`
