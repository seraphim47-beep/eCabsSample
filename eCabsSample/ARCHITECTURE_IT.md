# Architettura del progetto

## 1. Panoramica

`eCabsSample` è un'applicazione iOS UIKit che recupera e visualizza gli eventi pubblici di GitHub tramite l'endpoint REST `GET https://api.github.com/events`.

Il progetto adotta una separazione a livelli ispirata a **Clean Architecture**, con responsabilità distinte per avvio e navigazione, networking, accesso ai dati, dominio e presentazione. La schermata principale segue il pattern **MVVM**; `AppCoordinator` gestisce la navigazione, dando luogo a un'organizzazione **MVVM-C**.

L'interfaccia è realizzata con UIKit e XIB. La lista utilizza una `UICollectionView`.

## 2. Struttura delle cartelle

```text
eCabsSample/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppCoordinator.swift
├── Core/
│   ├── Networking/
│   │   ├── APIError.swift
│   │   ├── GitHubAPIClient.swift
│   │   ├── GitHubAPIResponse.swift
│   │   └── GitHubTokenStore.swift
│   ├── Extensions/
│   │   └── viewExtension.swift
│   └── Utilities/
│       └── DeviceInfo.swift
├── Data/
│   ├── DTO/
│   │   ├── GitHubEventDTO.swift
│   │   ├── GitHubActorDTO.swift
│   │   ├── GitHubRepositoryDTO.swift
│   │   └── GitHubEventDTO+Mapping.swift
│   ├── Repositories/
│   │   └── EventsRepository.swift
│   └── Services/
│       ├── AvatarLoader.swift
│       └── PollingService.swift
├── Domain/
│   ├── Models/
│   │   ├── GitHubEvent.swift
│   │   ├── JSONValue.swift
│   │   └── EventPayload/
│   ├── Protocols/
│   │   ├── EventsRepositoryProtocol.swift
│   │   └── GitHubAPIClientProtocol.swift
│   └── UseCases/
│       ├── MergeEventsUseCase.swift
│       └── FilterEventsUseCase.swift
├── Presentation/
│   ├── Events/
│   │   ├── EventsViewController.swift
│   │   ├── EventsViewController.xib
│   │   ├── EventsViewModel.swift
│   │   ├── EventCollectionViewCell.swift
│   │   └── EventCollectionViewCell.xib
│   ├── EventDetail/
│   │   ├── EventDetailViewController.swift
│   │   ├── EventDetailViewController.xib
│   │   └── EventDetailViewModel.swift
│   └── About/
│       ├── AboutViewController.swift
│       └── AboutViewController.xib
└── Resources/
    └── Localizable.xcstrings
```

## 3. App – Avvio e navigazione

### `AppDelegate.swift`

Gestisce il ciclo di vita generale dell'applicazione e fornisce la configurazione delle scene tramite `configurationForConnecting`.

### `SceneDelegate.swift`

Crea la `UIWindow` associata alla scena, istanzia `AppCoordinator` e ne avvia il flusso iniziale.

### `AppCoordinator.swift`

È il punto di composizione dell'applicazione. Crea e collega le dipendenze principali:

- `GitHubAPIClient`
- `MergeEventsUseCase`
- `EventsRepository`
- `EventsViewModel`
- `EventsViewController`

Crea inoltre il `UINavigationController` e gestisce la navigazione verso il dettaglio di un evento e la schermata About. Condivide un'istanza di `AvatarLoader` tra lista e dettaglio.

## 4. Core – Servizi infrastrutturali condivisi

### Networking

#### `GitHubAPIClient.swift`

Implementa `GitHubAPIClientProtocol` e gestisce le richieste HTTP verso GitHub. In particolare:

- invia una richiesta GET all'endpoint `/events`;
- configura gli header `Accept`, `X-GitHub-Api-Version` e `User-Agent`;
- aggiunge l'header `Authorization: Bearer` se è disponibile un Personal Access Token;
- invia l'ETag tramite `If-None-Match`;
- decodifica la risposta HTTP 200;
- gestisce la risposta HTTP 304 senza richiedere nuovamente il corpo degli eventi;
- legge e valida `X-Poll-Interval`, utilizzando 60 secondi come valore predefinito;
- interpreta gli errori HTTP e le informazioni di rate limit, inclusi `Retry-After`, `X-RateLimit-Remaining` e `X-RateLimit-Reset`.

Le richieste sono eseguite con `URLSession.data(for:)` e API Swift Concurrency.

#### `GitHubAPIResponse.swift`

Modella la risposta normalizzata del client API. Il risultato può essere una lista di DTO (`success`) oppure `notModified`; la struttura contiene anche ETag e intervallo di polling.

#### `APIError.swift`

Definisce gli errori applicativi relativi alla comunicazione: URL non valido, risposta non valida, errore HTTP, rate limit, errore di decoding ed errore di rete.

#### `GitHubTokenStore.swift`

È un actor che gestisce in modo asincrono il Personal Access Token nel Keychain iOS. Espone le operazioni di salvataggio, lettura e cancellazione. Il token viene conservato come elemento `kSecClassGenericPassword` ed è accessibile quando il dispositivo è sbloccato, solo su quel dispositivo.

### Utilities

#### `DeviceInfo.swift`

Centralizza le informazioni sul dispositivo e sull'orientamento dell'interfaccia. Espone proprietà per identificare i diversi idiom UIKit e l'orientamento corrente. È utilizzato, tra l'altro, per adattare la dimensione del font del controllo dei filtri su iPad.

### Extensions

#### `viewExtension.swift`

Contiene estensioni UIKit condivise. Le singole responsabilità dipendono dalle implementazioni presenti nel file.

## 5. Data – DTO, mapping, repository e servizi

### DTO

#### `GitHubEventDTO.swift`

Rappresenta la struttura grezza dell'evento ricevuto dall'API, prima della conversione nel modello di dominio.

#### `GitHubActorDTO.swift`

Rappresenta i dati dell'autore dell'evento restituiti dall'API, inclusi identificativo, login e URL dell'avatar.

#### `GitHubRepositoryDTO.swift`

Rappresenta i dati del repository associato all'evento.

#### `GitHubEventDTO+Mapping.swift`

Converte un `GitHubEventDTO` in `GitHubEvent`. Converte autore e repository nei rispettivi tipi Domain, interpreta la data ISO 8601 (con e senza frazioni di secondo) e delega la decodifica del payload a `GitHubEventPayload`.

Una data non interpretabile genera `MappingError.invalidDate`.

### Repository

#### `EventsRepository.swift`

È un actor che implementa `EventsRepositoryProtocol`. Coordina il client API e il caso d'uso di merge.

Responsabilità:

- conserva in memoria gli eventi già ricevuti;
- conserva l'ultimo ETag;
- converte i DTO in modelli Domain;
- unisce i nuovi eventi alla cache;
- restituisce la cache invariata quando il server risponde `304 Not Modified`;
- restituisce gli eventi, l'intervallo di polling e l'indicazione `wasModified`.

L'isolamento tramite actor protegge lo stato condiviso del repository.

### Services

#### `AvatarLoader.swift`

È un actor dedicato al caricamento asincrono degli avatar. Utilizza `URLSession`, una `NSCache` indicizzata per URL e una tabella di task in corso. In questo modo può riutilizzare immagini già caricate e condividere una stessa richiesta tra chiamate concorrenti per lo stesso URL.

#### `PollingService.swift`

Gestisce il ciclo di aggiornamento periodico. È isolato su `MainActor`, mantiene un task cancellabile e attende l'intervallo prima di invocare l'operazione. Se l'operazione restituisce un nuovo intervallo, questo viene applicato al ciclo successivo. L'intervallo minimo è un secondo.

## 6. Domain – Modelli, contratti e casi d'uso

Il Domain contiene i modelli indipendenti dalla presentazione e definisce i contratti utilizzati dai livelli esterni.

### Models

#### `GitHubEvent.swift`

È il modello principale dell'applicazione. Rappresenta identificativo, tipologia, autore, repository, payload, visibilità e data di creazione dell'evento.

#### `JSONValue.swift`

È un enum ricorsivo `Codable` e `Sendable` che rappresenta i tipi JSON fondamentali: stringhe, interi, numeri decimali, booleani, oggetti, array e `null`. Permette di conservare dati dinamici senza definire un modello rigido per ogni campo.

#### `EventPayload/`

`GitHubEventPayload.swift` associa il tipo di evento GitHub al relativo modello di payload. Sono gestiti i seguenti tipi:

- `PushEventPayload`
- `PullRequestEventPayload`
- `IssuesEventPayload`
- `WatchEventPayload`
- `ForkEventPayload`
- `CommitCommentEventPayload`
- `CreateEventPayload`
- `DeleteEventPayload`
- `DiscussionEventPayload`
- `GollumEventPayload`
- `IssueCommentEventPayload`
- `MemberEventPayload`
- `PublicEventPayload`
- `PullRequestReviewEventPayload`
- `PullRequestReviewCommentEventPayload`
- `ReleaseEventPayload`

I payload non riconosciuti o non decodificabili vengono conservati come `JSONValue` tramite il caso `.unknown`, evitando che un payload non previsto interrompa la conversione dell'evento.

### Protocols

#### `GitHubAPIClientProtocol.swift`

Definisce il contratto asincrono del client API, inclusa la richiesta condizionale con ETag. Consente al repository di dipendere da un'astrazione anziché dall'implementazione concreta.

#### `EventsRepositoryProtocol.swift`

Definisce il contratto asincrono per il recupero degli eventi. `EventsFetchResult` trasporta eventi, intervallo di polling e indicatore di modifica della risposta.

### Use Cases

#### `MergeEventsUseCase.swift`

Unisce gli eventi esistenti con quelli in ingresso, usa l'ID come chiave di deduplicazione e ordina il risultato per data decrescente. Se un ID è già presente, la versione in ingresso sostituisce quella precedente.

#### `FilterEventsUseCase.swift`

Filtra gli eventi in base all'insieme delle tipologie selezionate. Se l'insieme dei filtri è vuoto, restituisce tutti gli eventi.

## 7. Presentation – Schermate e ViewModel

### Events

#### `EventsViewController.swift`

Gestisce la schermata principale e la sua interfaccia UIKit: header, `UICollectionView`, filtri, indicatore di caricamento, messaggi di errore, pulsante di retry e footer.

Osserva gli aggiornamenti del `EventsViewModel` tramite la closure `onStateChange`. Gestisce il ciclo di vita del polling in relazione alla visibilità della schermata e inoltra al Coordinator le azioni di navigazione verso il dettaglio e About.

#### `EventsViewModel.swift`

Gestisce lo stato della lista e coordina `EventsRepositoryProtocol`, `FilterEventsUseCase` e `PollingService`.

Responsabilità:

- caricare gli eventi e aggiornare lo stato di caricamento;
- conservare gli eventi ricevuti e applicare i filtri;
- calcolare le tipologie disponibili, mantenendo un ordine preferenziale per i primi cinque tipi;
- esporre errori di rete, errori generici e messaggi di rate limit;
- aggiornare la data dell'ultimo aggiornamento quando la risposta contiene modifiche;
- avviare, riprendere e interrompere il polling;
- notificare la View tramite `onStateChange`.

#### `EventCollectionViewCell.swift` e `EventCollectionViewCell.xib`

Definiscono la cella della collection view. La cella mostra avatar, login, repository, data, tipo e descrizione dell'evento. Traduce le descrizioni e alcune informazioni sintetiche tramite le stringhe localizzate, assegna un colore in base al tipo di evento e carica l'avatar in modo asincrono. Il controllo dell'URL rappresentato evita di applicare a una cella riutilizzata il risultato relativo a un avatar precedente.

### EventDetail

#### `EventDetailViewModel.swift`

Trasforma un `GitHubEvent` nei dati pronti per la schermata di dettaglio: autore, avatar, tipo, data, visibilità, repository e sezioni di informazioni specifiche del payload.

Estrae i campi disponibili dai payload strutturati e dai valori JSON generici; valida gli URL prima di esporli come collegamenti.

#### `EventDetailViewController.swift` e `EventDetailViewController.xib`

Visualizzano le informazioni preparate dal ViewModel, costruendo dinamicamente le sezioni e le righe dei dettagli tramite `UIStackView`. Caricano l'avatar tramite `AvatarLoader` e permettono di aprire il repository associato.

### About

#### `AboutViewController.swift` e `AboutViewController.xib`

Mostrano le informazioni sull'applicazione, la versione, le tipologie di eventi supportate, le tecnologie utilizzate e il collegamento alla documentazione GitHub REST API.

La schermata include anche la gestione del Personal Access Token: inserimento, salvataggio, rimozione e visualizzazione dello stato di configurazione tramite `GitHubTokenStore`.

## 8. Flussi principali

### 8.1 Avvio e composizione delle dipendenze

```text
AppDelegate
    |
    v
SceneDelegate
    |
    v
AppCoordinator
    |
    +--> GitHubAPIClient
    +--> MergeEventsUseCase
    +--> EventsRepository
    +--> EventsViewModel
    |
    v
EventsViewController
```

### 8.2 Recupero e aggiornamento degli eventi

```text
EventsViewController
    |
    v
EventsViewModel
    |
    v
EventsRepositoryProtocol
    |
    v
EventsRepository
    |
    v
GitHubAPIClientProtocol
    |
    v
GitHubAPIClient
    |
    v
GitHub REST API
```

La risposta viene decodificata nei DTO, convertita nei modelli Domain e unita alla cache. In caso di HTTP 304 il repository mantiene gli eventi già memorizzati.

### 8.3 Filtraggio

```text
User selection
    |
    v
EventsViewController
    |
    v
EventsViewModel.updateFilters()
    |
    v
FilterEventsUseCase
    |
    v
Filtered GitHubEvent list
    |
    v
UICollectionView
```

### 8.4 Navigazione al dettaglio

```text
EventsViewController
    |
    | onSelectEvent(event)
    v
AppCoordinator
    |
    v
EventDetailViewModel
    |
    v
EventDetailViewController
```

## 9. Concorrenza e gestione dello stato

Il progetto utilizza Swift Concurrency per le operazioni asincrone:

- `GitHubAPIClient` esegue le richieste con `async/await`;
- `GitHubTokenStore`, `EventsRepository` e `AvatarLoader` sono actor, così da isolare il proprio stato;
- `EventsViewModel`, `EventsViewController`, `AppCoordinator` e `PollingService` sono isolati su `MainActor` dove dichiarato;
- `PollingService` mantiene e cancella il task di polling;
- `AvatarLoader` condivide i task di caricamento e conserva le immagini in cache.

La UI riceve gli aggiornamenti dal ViewModel tramite `onStateChange`.

## 10. Gestione di rete, cache e rate limit

Il client supporta richieste condizionali con ETag. Quando GitHub restituisce `304 Not Modified`, non è necessario decodificare nuovamente gli eventi e il repository restituisce la cache.

L'intervallo di polling viene letto da `X-Poll-Interval`; se manca o non è valido viene utilizzato il valore predefinito di 60 secondi. Il servizio di polling applica il valore ricevuto per la richiesta successiva.

Per gli errori di rate limit il client considera `Retry-After` e gli header `X-RateLimit-*`. Il ViewModel espone un messaggio localizzato e, quando è disponibile una data di reset, adegua l'intervallo prima del tentativo successivo.

Il Personal Access Token è opzionale: in sua assenza le richieste vengono effettuate senza autenticazione. Il token configurato nella schermata About viene conservato nel Keychain e aggiunto alla richiesta come Bearer token.

## 11. Localizzazione e risorse

`Resources/Localizable.xcstrings` contiene le stringhe localizzate utilizzate dall'interfaccia. Il progetto include risorse localizzate e utilizza `String(localized:)` per titoli, descrizioni, stati ed errori.

Le schermate e le celle sono definite tramite file XIB. Le immagini e gli altri asset grafici sono organizzati in `Assets.xcassets`.

## 12. Considerazioni progettuali

- **Separazione delle responsabilità:** networking, repository, dominio e presentazione hanno responsabilità distinte.
- **Dipendenze tramite protocolli:** il repository dipende da `GitHubAPIClientProtocol` e il ViewModel da `EventsRepositoryProtocol`.
- **Testabilità:** i protocolli consentono di sostituire le implementazioni concrete con mock nei test.
- **Resilienza ai payload:** i payload non riconosciuti o non decodificabili vengono mantenuti come JSON generico.
- **Efficienza delle richieste:** ETag, risposta 304 e intervallo imposto dal server riducono richieste e trasferimenti non necessari.
- **Efficienza delle immagini:** cache e deduplicazione delle richieste evitano download ripetuti degli avatar.
