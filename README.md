# GitHub Events

An iOS application to explore public activity on GitHub using the GitHub
REST API.

[English](#english) · [Italiano](#italiano)

------------------------------------------------------------------------

# English

## Overview

GitHub Events is a native iOS application developed using Swift and UIKit.

It retrieves public events from the GitHub REST API and displays them in a filterable list. 
Users can inspect the details of each event, explore the associated repository, and view information about the application.

The app follows a layered architecture, using MVVM for presentation and a Coordinator for navigation.

## Features

- Fetches public events from `https://api.github.com/events`.
- Displays events using a collection view.
- Provides filters by event type.
- Includes a detail screen with information extracted from the event payload.
- Loads actor avatars asynchronously and caches downloaded images.
- Periodically refreshes the event list according to the `X-Poll-Interval` header returned by GitHub.
- Uses ETag-based conditional requests to avoid downloading unchanged data.
- Handles HTTP errors and GitHub API rate limits.
- Supports Italian and English localization.
- Includes an About screen with application and API information.

### Supported event types

The app recognizes the following GitHub event payloads:

- Push
- Pull Request
- Issues
- Watch
- Fork
- Commit Comment
- Create
- Delete
- Discussion
- Gollum (Wiki)
- Issue Comment
- Member
- Public
- Pull Request Review
- Pull Request Review Comment
- Release

Unknown or unsupported payloads are preserved as generic JSON data whenever possible, so that an unfamiliar payload does not necessarily prevent the event from being displayed.

## Technologies

- **Language:** Swift
- **UI:** UIKit, UICollectionView, XIB
- **Concurrency:** Swift Concurrency (`async`/`await`, actors, `MainActor`)
- **Networking:** URLSession
- **API:** GitHub REST API
- **Image loading:** URLSession and NSCache
- **Credential storage:** iOS Keychain support through `GitHubTokenStore`
- **Architecture:** Layered Architecture, MVVM, Coordinator
- **Localization:** String Catalog (`Localizable.xcstrings`)
- **Testing:** XCTest

## Architecture

The codebase is organized into the following main layers:

| Layer | Responsibility |
|---|---|
| `App` | Application and scene lifecycle, dependency composition, and navigation |
| `Core` | Networking infrastructure, API errors, token management, and shared utilities |
| `Data` | API DTOs, mapping, repository implementation, and services |
| `Domain` | Event and payload models, protocols, and use cases |
| `Presentation` | Event list, event details, About screen, and related ViewModels |
| `Resources` | Localized strings and application resources |

For a more detailed description of the files and data flows, see `ARCHITECTURE_EN.md` and `ARCHITECTURE_IT.md`.

## Requirements

- Xcode
- An iOS Simulator or a supported iOS device
- An Internet connection to access the GitHub REST API

## GitHub API authentication

Requests to the GitHub API are initially unauthenticated. 
To authenticate them, create a Personal Access Token in your GitHub account settings and grant only the permissions strictly required. 
For reading public events, avoid unnecessary write permissions or repository access.

Then save the token on the About screen, accessible through the info button in the top-right corner of the home screen. 
The token is stored securely in the iOS Keychain using `GitHubTokenStore`.

## Polling, caching, and API rate limits

The app reads `X-Poll-Interval` from GitHub responses and uses 60 seconds when the header is missing or invalid. 
Polling waits for the configured interval before sending the next request.

The API client supports conditional requests through ETag and `If-None-Match`. When GitHub returns `304 Not Modified`, the repository keeps the events already stored in memory.

HTTP 403 and 429 responses are handled as rate-limit conditions when the response headers indicate that the limit has been reached. 
The app also considers the information provided by `Retry-After` and GitHub's `X-RateLimit-*` headers.

## Running the tests

Open the project in Xcode and run the tests using `Command + U` or **Product → Test**. Test documentation is available in Docs:

- `README_EN.md` — test documentation in English
- `README_IT.md` — test documentation in Italian

## Documentation

- `ARCHITECTURE_EN.md` — architecture documentation in English
- `ARCHITECTURE_IT.md` — architecture documentation in Italian


------------------------------------------------------------------------

# Italiano

## Panoramica

GitHub Events è un'applicazione iOS nativa sviluppata in Swift e UIKit.
Recupera gli eventi pubblici dalle API REST di GitHub e li mostra in un
elenco filtrabile. È possibile consultare i dettagli di ciascun evento,
esplorare il repository associato e visualizzare le informazioni
sull'applicazione.

L'app utilizza un'architettura a livelli, con MVVM per la presentazione
e un Coordinator per la navigazione.

## Funzionalità

-   Recupero degli eventi pubblici da `https://api.github.com/events`.
-   Visualizzazione degli eventi tramite collection view.
-   Filtri per tipologia di evento.
-   Schermata di dettaglio con informazioni estratte dal payload.
-   Caricamento asincrono degli avatar degli autori e cache delle
    immagini.
-   Aggiornamento periodico dell'elenco nel rispetto dell'header
    `X-Poll-Interval` restituito da GitHub.
-   Richieste condizionali tramite ETag per evitare di scaricare
    nuovamente dati invariati.
-   Gestione degli errori HTTP e dei limiti di richieste delle API
    GitHub.
-   Localizzazione in italiano e inglese.
-   Schermata About con informazioni sull'applicazione e sulle API.

### Tipologie di evento supportate

L'app riconosce i seguenti payload GitHub:

-   Push
-   Pull Request
-   Issues
-   Watch
-   Fork
-   Commit Comment
-   Create
-   Delete
-   Discussion
-   Gollum (Wiki)
-   Issue Comment
-   Member
-   Public
-   Pull Request Review
-   Pull Request Review Comment
-   Release

I payload sconosciuti o non supportati vengono conservati, quando
possibile, come dati JSON generici, così da non impedire necessariamente
la visualizzazione dell'evento.

## Tecnologie utilizzate

-   **Linguaggio:** Swift
-   **Interfaccia:** UIKit, UICollectionView, XIB
-   **Concorrenza:** Swift Concurrency (`async`/`await`, actor,
    `MainActor`)
-   **Networking:** URLSession
-   **API:** GitHub REST API
-   **Caricamento immagini:** URLSession e NSCache
-   **Persistenza credenziali:** è presente il supporto a iOS Keychain
    tramite `GitHubTokenStore`
-   **Architettura:** architettura a livelli, MVVM, Coordinator
-   **Localizzazione:** String Catalog (`Localizable.xcstrings`)
-   **Test:** XCTest

## Architettura

Il codice è organizzato nei seguenti livelli principali:

  ---------------------------------------------------------------------
  Livello                            Responsabilità
  ---------------------------------- ----------------------------------
  `App`                              Ciclo di vita dell'app e delle
                                     scene, composizione delle
                                     dipendenze e navigazione

  `Core`                             Infrastruttura di rete, errori
                                     API, gestione del token e utility
                                     condivise

  `Data`                             DTO delle API, mapping,
                                     implementazione del repository e
                                     servizi

  `Domain`                           Modelli degli eventi e dei
                                     payload, protocolli e casi d'uso

  `Presentation`                     Lista eventi, dettaglio, schermata
                                     About e relativi ViewModel

  `Resources`                        Stringhe localizzate e risorse
                                     dell'applicazione
  ---------------------------------------------------------------------

Per una descrizione più dettagliata dei file e dei flussi dei dati,
consulta `ARCHITECTURE_IT.md` e `ARCHITECTURE_EN.md`.

## Requisiti

-   Xcode
-   Un simulatore iOS oppure un dispositivo iOS supportato
-   Connessione Internet per raggiungere le API REST di GitHub

- Le request alle api di GitHub non sono autenticate, per autenticarle 
crea un token dalle impostazioni del tuo account GitHub e concedi
soltanto i permessi strettamente necessari. Per la lettura degli eventi
pubblici, evita permessi di scrittura o accessi ai repository non
necessari, poi va salvato nella pagina About (raggiungibile dal bottone info
in alto a destra nella schermata iniziale, il token viene poi salvato tramite
GitHubTokenStore nel portachiavi iOS.

### Stato attuale dell'implementazione

## Polling, cache e limiti API

L'app legge `X-Poll-Interval` dalle risposte di GitHub e utilizza 60
secondi quando l'header è assente o non valido. Il polling attende
l'intervallo configurato prima di inviare la richiesta successiva.

Il client API supporta le richieste condizionali tramite ETag e
`If-None-Match`. Quando GitHub restituisce `304 Not Modified`, il
repository conserva gli eventi già presenti in memoria.

Le risposte HTTP 403 e 429 vengono gestite come condizioni di rate limit
quando gli header indicano che il limite è stato raggiunto. Vengono
inoltre considerate le informazioni contenute in `Retry-After` e negli
header GitHub `X-RateLimit-*`.

## Esecuzione dei test

Apri il progetto in Xcode ed esegui i test con `Command + U` oppure
tramite **Product → Test**. La documentazione dei test è disponibile in Docs:

-   `README_IT.md` --- documentazione dei test in italiano
-   `README_EN.md` --- documentazione dei test in inglese

## Documentazione

-   `ARCHITECTURE_IT.md` --- documentazione dell'architettura in
    italiano
-   `ARCHITECTURE_EN.md` --- documentazione dell'architettura in inglese
