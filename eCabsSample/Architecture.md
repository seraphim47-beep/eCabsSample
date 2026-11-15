//
//  Architecture.md
//  eCabsSample
//
//  Created by Matteo Savoldelli on 15/11/2026.
//

# Project Architecture – File Responsibilities
# Architettura del progetto – Responsabilità dei file

## 1. Networking

### `APIError.swift`

**EN:** Defines the network and API errors that can occur when communicating with GitHub. It also provides localized error descriptions to make failures easier to display and understand.

**IT:** Definisce gli errori di rete e gli errori API che possono verificarsi durante la comunicazione con GitHub. Fornisce inoltre descrizioni leggibili degli errori, utili per mostrarli e interpretarli nell'interfaccia.

### `GitHubAPIClient.swift`

**EN:** Handles HTTP communication with the GitHub REST API. It fetches public events, configures request headers, supports ETag-based conditional requests, reads the server polling interval, and handles HTTP errors and rate limits.

**IT:** Gestisce la comunicazione HTTP con le API REST di GitHub. Recupera gli eventi pubblici, configura gli header delle richieste, supporta le richieste condizionali tramite ETag, legge l'intervallo di polling indicato dal server e gestisce gli errori HTTP e i limiti di richieste.

### `GitHubAPIResponse.swift`

**EN:** Defines the response structure returned by the API client. It distinguishes between a successful response containing events and a `304 Not Modified` response, while also carrying the ETag and polling interval.

**IT:** Definisce la struttura della risposta restituita dal client API. Distingue tra una risposta contenente nuovi eventi e una risposta `304 Not Modified`, mantenendo anche l'ETag e l'intervallo di polling.

---

## 2. Data – DTO and Mapping

### `GitHubEventDTO.swift`

**EN:** Represents the raw event data received from the GitHub API, including the event ID, type, actor, repository, payload, visibility, and creation date.

**IT:** Rappresenta i dati grezzi di un evento ricevuto dalle API GitHub, inclusi ID, tipologia, autore, repository, payload, visibilità e data di creazione.

### `GitHubActorDTO.swift`

**EN:** Represents the GitHub user or actor associated with an event, including their ID, username, display login, and avatar URL.

**IT:** Rappresenta l'utente GitHub associato a un evento, includendo ID, username, nome visualizzato e URL dell'immagine del profilo.

### `GitHubRepositoryDTO.swift`

**EN:** Represents the repository associated with an event, including its ID, name, and API URL.

**IT:** Rappresenta il repository associato a un evento, includendo ID, nome e URL delle API GitHub.

### `GitHubEventDTO+Mapping.swift`

**EN:** Converts an API event DTO into the corresponding domain model. It also parses the event creation date and decodes the appropriate event payload.

**IT:** Converte un DTO ricevuto dalle API nel corrispondente modello del Domain. Si occupa inoltre di convertire la data di creazione e decodificare il payload specifico dell'evento.

---

## 3. Domain – Models and Protocols

### `JSONValue.swift`

**EN:** Provides a generic representation of JSON values, allowing the application to handle dynamic or unknown payload structures without requiring a dedicated model for every field.

**IT:** Fornisce una rappresentazione generica dei valori JSON, permettendo all'applicazione di gestire strutture dinamiche o sconosciute senza dover creare un modello specifico per ogni campo.

### `GitHubEventPayload.swift`

**EN:** Defines the supported GitHub event payload types and maps each event type to its corresponding payload model. Unknown event types are preserved as generic JSON values.

**IT:** Definisce le tipologie di payload GitHub supportate e associa ogni tipo di evento al relativo modello. Gli eventi non riconosciuti vengono conservati come valori JSON generici.

### `PushEventPayload.swift`

**EN:** Represents the payload of a GitHub `PushEvent`, including the branch reference, push ID, head commit, and previous commit.

**IT:** Rappresenta il payload di un evento GitHub `PushEvent`, includendo il riferimento al branch, l'ID del push, il commit corrente e quello precedente.

### `PullRequestEventPayload.swift`

**EN:** Represents the payload of a `PullRequestEvent`, including its action, number, and pull request data.

**IT:** Rappresenta il payload di un evento `PullRequestEvent`, includendo l'azione eseguita, il numero e i dati della Pull Request.

### `IssuesEventPayload.swift`

**EN:** Represents the payload of an `IssuesEvent`, including its action, issue data, assignees, and labels.

**IT:** Rappresenta il payload di un evento `IssuesEvent`, includendo l'azione eseguita, i dati della Issue, gli assegnatari e le etichette.

### `WatchEventPayload.swift`

**EN:** Represents the payload of a `WatchEvent`, including the action performed by the user.

**IT:** Rappresenta il payload di un evento `WatchEvent`, includendo l'azione eseguita dall'utente.

### `ForkEventPayload.swift`

**EN:** Represents the payload of a `ForkEvent`, including information about the newly created repository.

**IT:** Rappresenta il payload di un evento `ForkEvent`, includendo le informazioni sul nuovo repository creato.

### `EventsRepositoryProtocol.swift`

**EN:** Defines the contract for retrieving GitHub events, separating the domain layer from the concrete data implementation.

**IT:** Definisce il contratto per il recupero degli eventi GitHub, separando il Domain dall'implementazione concreta del livello Data.

---

## 4. Data – Repository

### `EventsRepository.swift`

**EN:** Implements the events repository. It coordinates API requests, maps DTOs into domain models, maintains an in-memory event cache, handles ETag-based responses, and merges incoming events while removing duplicates.

**IT:** Implementa il repository degli eventi. Coordina le richieste API, converte i DTO in modelli Domain, mantiene una cache degli eventi in memoria, gestisce le risposte basate su ETag e unisce gli eventi ricevuti eliminando i duplicati.

---

## 5. Data Flow – Flusso dei dati

```text
GitHub REST API
      |
      v
GitHubAPIClient
      |
      v
EventsRepository
      |
      v
Domain Models
      |
      v
Presentation Layer
(ViewModels and ViewControllers)
```

**EN:** The networking layer handles communication with GitHub. The data layer transforms and stores the received data, while the domain layer defines the models and contracts used throughout the application.

**IT:** Il livello Networking gestisce la comunicazione con GitHub. Il livello Data trasforma e conserva i dati ricevuti, mentre il Domain definisce i modelli e i contratti utilizzati all'interno dell'applicazione.

**EN:** This separation makes the application easier to maintain, test, and extend, without tightly coupling the user interface to the API implementation.

**IT:** Questa separazione rende l'applicazione più semplice da mantenere, testare ed estendere, evitando di accoppiare direttamente l'interfaccia utente all'implementazione delle API.
