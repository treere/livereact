## ADDED Requirements

### Requirement: Pagina unica su `/`
Il sistema SHALL servire su `/` il guscio LiveView (header con totale, footer carrello) con l'isola React montata, senza alcun branch per vista pura.

#### Scenario: Home mostra guscio e isola
- **WHEN** utente apre `/`
- **THEN** vede header "Mercatino", `div#react-island[phx-hook="ReactApp"]` e footer carrello, senza lista baseline né link di navigazione tra viste

### Requirement: Route `/play` rimossa
Il sistema SHALL NON servire più alcuna pagina su `/play` (404 del router).

#### Scenario: Vecchio URL
- **WHEN** utente apre `/play`
- **THEN** riceve 404

## REMOVED Requirements

### Requirement: Vista baseline LiveView pura
**Reason**: Scopo didattico del confronto esaurito; raddoppiava template e route.
**Migration**: Usare `/`, che ora ospita guscio+isola.
