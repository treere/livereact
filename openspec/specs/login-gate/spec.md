# login-gate

Purpose: TBD — LiveView consapevole dello stato di login con gate sul market.

## Requirements

### Requirement: LiveView consapevole dello stato di login
The system SHALL make `ShopLive` aware of login state from the signed-cookie session and gate the market accordingly.

#### Scenario: Mount assegna current_user dalla sessione
- **WHEN** il socket LiveView si connette con sessione contenente `username = "mario"`
- **THEN** `ShopLive.mount/3` assegna `current_user = "mario"` (e `display_name` se presente)

#### Scenario: Anonimo vede solo login
- **WHEN** il socket LiveView si connette senza `username` in sessione
- **THEN** `current_user` è `nil` e il render espone `data-current-user` vuoto così React monta solo il `LoginForm`

#### Scenario: Eventi market richiedono login
- **WHEN** un socket anonimo invia `add-to-cart`, `remove-from-cart` o `clear-cart`
- **THEN** la LiveView ignora l'evento senza modificare carrello né broadcast (difesa oltre al gate UI)

#### Scenario: UI market solo per loggati
- **WHEN** un utente loggato apre `/`
- **THEN** React monta l'isola market (filtro, lista, aggiungi) con header che mostra lo username e bottone "Esci", senza alcun form login visibile
