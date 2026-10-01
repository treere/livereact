# react-bridge

Purpose: TBD — ponte bidirezionale tra LiveView e isola React.

## Requirements

### Requirement: Montaggio isolato dell'isola React
Il sistema SHALL montare l'isola React dentro `div#react-island[phx-hook="ReactApp"][phx-update="ignore"]`, montare `createRoot` una sola volta in `mounted` e smontarlo in `destroyed` con rimozione dei listener.

#### Scenario: Update LV non smonta React
- **WHEN** LiveView fa re-render di header/footer (es. totale carrello)
- **THEN** la root React resta montata e filtro/selezione locali non si resettano

### Requirement: Flusso LV verso React
Il sistema SHALL inoltrare `push_event("items-updated")` e `push_event("cart-updated")` dall'Hook a React (via re-render con nuove props o `CustomEvent` interno) senza ricaricare la pagina.

#### Scenario: Totale si aggiorna live
- **WHEN** il server broadcastta `cart-updated {cart, total}`
- **THEN** l'isola React mostra il nuovo totale entro il round-trip websocket

### Requirement: Flusso React verso LV
Il sistema SHALL permettere a React di inviare intenzioni (`add-to-cart`, `remove-from-cart`) tramite `CustomEvent("lv:send")` intercettato dall'Hook che chiama `pushEvent` con ack opzionale.

#### Scenario: Click aggiunge al carrello
- **WHEN** utente clicca "Aggiungi" sulla card mela in React
- **THEN** il server riceve `add-to-cart {id: "mela"}` e risponde con broadcast `cart-updated`

### Requirement: Stato locale React mai sincronizzato
Il sistema SHALL tenere `filterText` e `selectedId` solo in `useState` React, senza inviarli mai al server.

#### Scenario: Filtro non tocca la rete
- **WHEN** utente digita nel filtro
- **THEN** la lista si filtra istantaneamente e nessun evento websocket parte
