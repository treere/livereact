# cookie-auth

Purpose: TBD — login username-only via HTTP con sessione cookie firmata.

## Requirements

### Requirement: Login cookie-based username-only via HTTP
The system SHALL provide username-only login via HTTP JSON that establishes a signed-cookie session reused by LiveView.

#### Scenario: Login con username valido
- **WHEN** un client anonimo invia `POST /api/session` con body `{"username": "  Mario "}` e CSRF valido
- **THEN** il sistema risponde `201` con `{"username": "mario", "display_name": "Mario"}`, rinnova la sessione e imposta il cookie firmato `_livereact_key`

#### Scenario: Username mancante o vuoto respinto
- **WHEN** un client invia `POST /api/session` con username assente, vuoto o solo spazi
- **THEN** il sistema risponde `422` con `{"error": "username richiesto"}` e non imposta alcuna sessione

#### Scenario: Username troppo lungo respinto
- **WHEN** un client invia `POST /api/session` con username oltre 32 caratteri (dopo trim)
- **THEN** il sistema risponde `422` e non imposta alcuna sessione

#### Scenario: Stesso username normalizzato uguale stesso utente
- **WHEN** due browser diversi fanno login con `"Mario"`, `" mario "` e `"MARIO"`
- **THEN** entrambe le sessioni risultano autenticate come identità `mario` (stesso utente logico)

#### Scenario: Logout cancella la sessione
- **WHEN** un client autenticato invia `DELETE /api/session`
- **THEN** il sistema pulisce la sessione, risponde `200` con `{"ok": true}` e le successive connessioni LiveView risultano anonime

### Requirement: Form login interamente in React
The system SHALL render the login UI exclusively with React (text field username + bottone "Entra") che chiama il BE via HTTP.

#### Scenario: Vista login React per anonimi
- **WHEN** un utente anonimo apre `/`
- **THEN** vede un input text (placeholder username) e un bottone "Entra" renderizzati da React, e nessun elemento del market

#### Scenario: Login React chiama il BE via HTTP
- **WHEN** l'utente digita uno username e clicca "Entra"
- **THEN** il componente React esegue `fetch POST /api/session` con `credentials: "same-origin"`, header CSRF e body JSON, senza alcun form HEEx né `phx-submit`

#### Scenario: Dopo login React mostra il market
- **WHEN** la chiamata `POST /api/session` risponde `201`
- **THEN** il client ricarica/riconnette la LiveView col nuovo cookie e React mostra il market con indicazione dell'utente loggato

#### Scenario: Logout da React
- **WHEN** l'utente loggato clicca "Esci" in React
- **THEN** il componente esegue `fetch DELETE /api/session` e poi mostra di nuovo il form login
