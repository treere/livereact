# mercatino-shop

Purpose: TBD — catalogo condiviso e carrello broadcast del mercatino toy.

## Requirements

### Requirement: Catalogo condiviso LiveView
Il sistema SHALL esporre un catalogo hardcoded di 3-4 prodotti (id, name, price) disponibile sia alla pagina LV pura che come snapshot iniziale all'isola React.

#### Scenario: Snapshot iniziale
- **WHEN** utente apre `/play`
- **THEN** l'isola React riceve la lista completa dei prodotti con prezzi

### Requirement: Carrello condiviso con broadcast
Il sistema SHALL mantenere `cart` e `total` negli assign, ricalcolare il totale a ogni modifica e fare broadcast `cart-updated` a tutti i client sottoscritti allo stesso topic.

#### Scenario: Aggiunta visibile in due browser
- **WHEN** browser A invia `add-to-cart {id: "mela"}`
- **THEN** browser A e browser B vedono carrello e totale aggiornati senza reload

#### Scenario: Rimozione e svuotamento
- **WHEN** utente invia `remove-from-cart {id}` o `clear-cart {}`
- **THEN** il sistema rimuove la riga o svuota il carrello e ribroadcastta il nuovo totale

### Requirement: Validazione centralizzata senza auth
Il sistema SHALL validare ogni `id` ricevuto in `handle_event` (id esistente, quantità >= 0) e ignorare payload malformati senza crashare.

#### Scenario: Id sconosciuto
- **WHEN** arriva `add-to-cart {id: "inesistente"}`
- **THEN** il sistema ignora l'evento e lo stato resta invariato
