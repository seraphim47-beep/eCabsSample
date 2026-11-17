# Project Architecture

## 1. Overview

`eCabsSample` is a UIKit-based iOS application that retrieves and displays public GitHub events through the REST endpoint `GET https://api.github.com/events`.

The project follows a layered separation inspired by **Clean Architecture**, with distinct responsibilities for application startup and navigation, networking, data access, domain logic, and presentation. The main screen follows **MVVM**; `AppCoordinator` handles navigation, resulting in an **MVVM-C** organization.

The UI is built with UIKit and XIB files. The event list uses a `UICollectionView`.

## 2. Folder structure

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

## 3. App – Startup and navigation

### `AppDelegate.swift`

Manages the application-level lifecycle and provides scene configuration through `configurationForConnecting`.

### `SceneDelegate.swift`

Creates the `UIWindow` associated with the scene, instantiates `AppCoordinator`, and starts the initial application flow.

### `AppCoordinator.swift`

Acts as the application's composition root. It creates and wires the main dependencies:

- `GitHubAPIClient`
- `MergeEventsUseCase`
- `EventsRepository`
- `EventsViewModel`
- `EventsViewController`

It also creates the `UINavigationController` and handles navigation to an event detail screen and the About screen. A single `AvatarLoader` instance is shared between the list and detail screens.

## 4. Core – Shared infrastructure

### Networking

#### `GitHubAPIClient.swift`

Implements `GitHubAPIClientProtocol` and handles HTTP requests to GitHub. Its responsibilities include:

- sending a GET request to the `/events` endpoint;
- configuring the `Accept`, `X-GitHub-Api-Version`, and `User-Agent` headers;
- adding an `Authorization: Bearer` header when a Personal Access Token is available;
- sending the ETag through `If-None-Match`;
- decoding HTTP 200 responses;
- handling HTTP 304 responses without downloading and decoding the event body again;
- reading and validating `X-Poll-Interval`, with a default value of 60 seconds;
- interpreting HTTP errors and rate limit information, including `Retry-After`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset`.

Requests are executed using `URLSession.data(for:)` and Swift Concurrency.

#### `GitHubAPIResponse.swift`

Defines the normalized response returned by the API client. The result can contain a list of DTOs (`success`) or be `notModified`; the structure also carries the ETag and polling interval.

#### `APIError.swift`

Defines application errors related to communication: invalid URL, invalid response, HTTP error, rate limit, decoding error, and network error.

#### `GitHubTokenStore.swift`

An actor that asynchronously manages the Personal Access Token in the iOS Keychain. It exposes save, read, and delete operations. The token is stored as a `kSecClassGenericPassword` item and is accessible while the device is unlocked, on this device only.

### Utilities

#### `DeviceInfo.swift`

Centralizes information about the current device and interface orientation. It exposes properties to identify UIKit device idioms and the current interface orientation. It is used, among other things, to adapt the filter control's font size on iPad.

### Extensions

#### `viewExtension.swift`

Contains shared UIKit extensions. The specific responsibilities depend on the implementations contained in the file.

## 5. Data – DTOs, mapping, repository, and services

### DTOs

#### `GitHubEventDTO.swift`

Represents the raw event structure received from the API before it is converted into the domain model.

#### `GitHubActorDTO.swift`

Represents the event actor data returned by the API, including identifier, login, and avatar URL.

#### `GitHubRepositoryDTO.swift`

Represents the repository data associated with an event.

#### `GitHubEventDTO+Mapping.swift`

Converts a `GitHubEventDTO` into a `GitHubEvent`. It maps actor and repository data into their Domain types, parses the ISO 8601 creation date (with and without fractional seconds), and delegates payload decoding to `GitHubEventPayload`.

An unparseable date produces `MappingError.invalidDate`.

### Repository

#### `EventsRepository.swift`

An actor implementing `EventsRepositoryProtocol`. It coordinates the API client and the merge use case.

Responsibilities:

- keeps previously received events in memory;
- stores the latest ETag;
- converts DTOs into Domain models;
- merges incoming events into the cache;
- returns the unchanged cache when the server responds with `304 Not Modified`;
- returns the events, polling interval, and `wasModified` flag.

Actor isolation protects the repository's shared state.

### Services

#### `AvatarLoader.swift`

An actor dedicated to asynchronous avatar loading. It uses `URLSession`, an `NSCache` indexed by URL, and a table of in-flight tasks. This allows it to reuse previously loaded images and share a single request among concurrent calls for the same URL.

#### `PollingService.swift`

Manages periodic refreshes. It is isolated to `MainActor`, maintains a cancellable task, and waits for the configured interval before invoking the operation. If the operation returns a new interval, that value is used for the next cycle. The minimum interval is one second.

## 6. Domain – Models, contracts, and use cases

The Domain layer contains models independent of presentation and defines the contracts used by outer layers.

### Models

#### `GitHubEvent.swift`

The application's main event model. It represents the event identifier, type, actor, repository, payload, visibility, and creation date.

#### `JSONValue.swift`

A recursive `Codable` and `Sendable` enum representing the fundamental JSON types: strings, integers, floating-point numbers, booleans, objects, arrays, and `null`. It allows dynamic data to be preserved without defining a rigid model for every field.

#### `EventPayload/`

`GitHubEventPayload.swift` maps GitHub event types to their corresponding payload models. The following types are handled:

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

Unrecognized or undecodable payloads are preserved as `JSONValue` through the `.unknown` case, preventing an unsupported payload from interrupting event mapping.

### Protocols

#### `GitHubAPIClientProtocol.swift`

Defines the asynchronous API client contract, including conditional requests using an ETag. It allows the repository to depend on an abstraction rather than a concrete implementation.

#### `EventsRepositoryProtocol.swift`

Defines the asynchronous contract for fetching events. `EventsFetchResult` carries the events, polling interval, and response modification flag.

### Use Cases

#### `MergeEventsUseCase.swift`

Merges existing events with incoming ones, uses the event ID as the deduplication key, and sorts the result by descending creation date. If an ID already exists, the incoming version replaces the previous one.

#### `FilterEventsUseCase.swift`

Filters events using the selected event type set. If the filter set is empty, all events are returned.

## 7. Presentation – Screens and ViewModels

### Events

#### `EventsViewController.swift`

Manages the main screen and its UIKit interface: header, `UICollectionView`, filters, loading indicator, error messages, retry button, and footer.

It observes `EventsViewModel` updates through the `onStateChange` closure. It manages polling according to the screen's visibility and forwards navigation actions for event details and About to the Coordinator.

#### `EventsViewModel.swift`

Manages list state and coordinates `EventsRepositoryProtocol`, `FilterEventsUseCase`, and `PollingService`.

Responsibilities:

- fetches events and updates the loading state;
- stores received events and applies filters;
- calculates available event types, keeping a preferred order for the first five types;
- exposes network errors, generic errors, and rate limit messages;
- updates the last-refresh date when the response contains changes;
- starts, resumes, and stops polling;
- notifies the View through `onStateChange`.

#### `EventCollectionViewCell.swift` and `EventCollectionViewCell.xib`

Define the collection view cell. The cell displays the avatar, login, repository, date, event type, and event description. It localizes descriptions and selected summary details, applies a color based on event type, and loads the avatar asynchronously. Checking the represented URL prevents a reused cell from displaying the result of a previous avatar request.

### EventDetail

#### `EventDetailViewModel.swift`

Transforms a `GitHubEvent` into the data required by the detail screen: actor, avatar, type, date, visibility, repository, and payload-specific information sections.

It extracts available fields from typed payloads and generic JSON values, and validates URLs before exposing them as links.

#### `EventDetailViewController.swift` and `EventDetailViewController.xib`

Display the information prepared by the ViewModel, dynamically building detail sections and rows using `UIStackView`. They load the avatar through `AvatarLoader` and allow the associated repository to be opened.

### About

#### `AboutViewController.swift` and `AboutViewController.xib`

Display application information, version, supported event types, technologies, and a link to the GitHub REST API documentation.
The screen also includes Personal Access Token management: entry, saving, removal, and configuration status display through `GitHubTokenStore`.

## 8. Main flows

### 8.1 Startup and dependency composition

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

### 8.2 Fetching and refreshing events

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

The response is decoded into DTOs, mapped to Domain models, and merged into the cache. On HTTP 304, the repository keeps the events already stored.

### 8.3 Filtering

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

### 8.4 Navigation to event details

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

## 9. Concurrency and state management

The project uses Swift Concurrency for asynchronous operations:

- `GitHubAPIClient` performs requests using `async/await`;
- `GitHubTokenStore`, `EventsRepository`, and `AvatarLoader` are actors, isolating their internal state;
- `EventsViewModel`, `EventsViewController`, `AppCoordinator`, and `PollingService` are isolated to `MainActor` where declared;
- `PollingService` owns and cancels the polling task;
- `AvatarLoader` shares in-flight tasks and caches images.

The UI receives ViewModel updates through `onStateChange`.

## 10. Networking, caching, and rate limit handling

The client supports conditional requests using ETags. When GitHub returns `304 Not Modified`, events do not need to be decoded again and the repository returns its cache.

The polling interval is read from `X-Poll-Interval`; if the header is missing or invalid, the default value of 60 seconds is used. The polling service applies the received value to the next request.

For rate limit errors, the client considers `Retry-After` and the `X-RateLimit-*` headers. The ViewModel exposes a localized message and, when a reset date is available, adjusts the interval before the next attempt.

A Personal Access Token is optional: without one, requests are made anonymously. A token configured in the About screen is stored in the Keychain and added to requests as a Bearer token.

## 11. Localization and resources

`Resources/Localizable.xcstrings` contains the localized strings used by the interface. The project includes localized resources and uses `String(localized:)` for titles, descriptions, states, and errors.

Screens and cells are defined using XIB files. Images and other visual assets are organized in `Assets.xcassets`.

## 12. Design considerations

- **Separation of concerns:** networking, repository, domain, and presentation have distinct responsibilities.
- **Protocol-based dependencies:** the repository depends on `GitHubAPIClientProtocol`, while the ViewModel depends on `EventsRepositoryProtocol`.
- **Testability:** protocols allow concrete implementations to be replaced with mocks in tests.
- **Payload resilience:** unrecognized or undecodable payloads are preserved as generic JSON.
- **Request efficiency:** ETags, HTTP 304 responses, and the server-provided polling interval reduce unnecessary requests and data transfers.
- **Image efficiency:** caching and request coalescing prevent repeated avatar downloads.
