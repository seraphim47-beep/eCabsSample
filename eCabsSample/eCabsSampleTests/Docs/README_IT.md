# GitHub Events -- Documentazione dei test

**Framework:** XCTest · **Linguaggio:** Swift · **Suite:** 9 · **Test
documentati:** 54

## Introduzione

Questa documentazione descrive i test automatizzati del progetto GitHub
Events. La suite verifica la logica applicativa, la gestione degli
eventi GitHub, le richieste HTTP, il polling, la cache delle immagini e
l'autenticazione tramite Keychain. I test utilizzano XCTest e, dove
necessario, mock e `URLProtocol` personalizzati.

## MergeEventsUseCaseTests --- 5 test

  --------------------------------------------------------------------------------------
  Metodo                                             Descrizione
  -------------------------------------------------- -----------------------------------
  `testExecuteMergesExistingAndIncomingEvents`       Verifica l'unione di due liste di
                                                     eventi.

  `testExecuteRemovesDuplicateEvents`                Verifica la rimozione degli eventi
                                                     con identificativo duplicato.

  `testExecuteIncomingEventOverridesExistingEvent`   Verifica che l'evento in ingresso
                                                     sostituisca quello già presente.

  `testExecuteSortsEventsByDateDescending`           Verifica l'ordinamento dal più
                                                     recente al meno recente.

  `testExecuteReturnsEmptyArrayWhenInputsAreEmpty`   Verifica il comportamento con liste
                                                     vuote.
  --------------------------------------------------------------------------------------

## FilterEventsUseCaseTests --- 5 test

  -------------------------------------------------------------------------------------------
  Metodo                                                  Descrizione
  ------------------------------------------------------- -----------------------------------
  `testExecuteReturnsAllEventsWhenNoFiltersAreSelected`   Verifica che senza filtri vengano
                                                          restituiti tutti gli eventi.

  `testExecuteFiltersEventsBySingleType`                  Verifica il filtro per una singola
                                                          tipologia.

  `testExecuteFiltersEventsByMultipleTypes`               Verifica il filtro per più
                                                          tipologie.

  `testExecuteReturnsEmptyArrayWhenNoEventsMatch`         Verifica il risultato vuoto quando
                                                          nessun evento corrisponde ai
                                                          filtri.

  `testExecuteReturnsEmptyArrayWhenInputIsEmpty`          Verifica il comportamento con una
                                                          lista iniziale vuota.
  -------------------------------------------------------------------------------------------

## EventsRepositoryTests --- 5 test

  ------------------------------------------------------------------------------------------
  Metodo                                                 Descrizione
  ------------------------------------------------------ -----------------------------------
  `testFetchEventsStoresInitialEvents`                   Verifica il recupero e la
                                                         memorizzazione degli eventi
                                                         iniziali.

  `testFetchEventsMergesNewEventsAndRemovesDuplicates`   Verifica merge e deduplicazione
                                                         degli eventi.

  `testFetchEventsKeepsCacheWhenResponseIsNotModified`   Verifica la conservazione della
                                                         cache in caso di HTTP 304.

  `testFetchEventsPreservesAndUpdatesETag`               Verifica aggiornamento e
                                                         conservazione dell'ETag.

  `testFetchEventsPropagatesAPIError`                    Verifica la propagazione degli
                                                         errori dell'API client.
  ------------------------------------------------------------------------------------------

## EventsViewModelTests --- 9 test

  -----------------------------------------------------------------------------------------------
  Metodo                                                      Descrizione
  ----------------------------------------------------------- -----------------------------------
  `testLoadEventsUpdatesViewModelState`                       Verifica l'aggiornamento dello
                                                              stato del ViewModel durante il
                                                              caricamento.

  `testLoadEventsHandlesEmptyResponse`                        Verifica la gestione di una
                                                              risposta senza eventi.

  `testUpdateFiltersReturnsOnlySelectedEventTypes`            Verifica la visualizzazione dei
                                                              soli eventi selezionati.

  `testUpdateFiltersWithEmptySelectionReturnsAllEvents`       Verifica che rimuovendo i filtri
                                                              vengano mostrati tutti gli eventi.

  `testLoadEventsHandlesNetworkError`                         Verifica la gestione degli errori
                                                              di rete.

  `testLoadEventsUpdatesAvailableEventTypes`                  Verifica le tipologie di evento
                                                              esposte dal ViewModel.

  `testLoadEventsHandlesRateLimitWithResetDate`               Verifica il rate limit quando è
                                                              disponibile una data di ripristino.

  `testLoadEventsHandlesRateLimitWithoutResetDate`            Verifica il rate limit senza data
                                                              di ripristino.

  `testLoadEventsPreservesPreviouslyLoadedEventsAfterError`   Verifica la conservazione degli
                                                              eventi già caricati dopo un errore
                                                              successivo.
  -----------------------------------------------------------------------------------------------

## GitHubAPIClientTests --- 9 test

  -------------------------------------------------------------------------------------------------
  Metodo                                                        Descrizione
  ------------------------------------------------------------- -----------------------------------
  `testFetchEventsReturnsEventsOnHTTP200`                       Verifica il decoding degli eventi
                                                                con risposta HTTP 200.

  `testFetchEventsReturnsNotModifiedOnHTTP304`                  Verifica la gestione della risposta
                                                                Not Modified.

  `testFetchEventsSendsETagHeader`                              Verifica l'invio dell'ETag
                                                                nell'header `If-None-Match`.

  `testFetchEventsUsesDefaultPollIntervalWhenHeaderIsMissing`   Verifica l'intervallo predefinito
                                                                quando l'header manca.

  `testFetchEventsUsesDefaultPollIntervalWhenHeaderIsInvalid`   Verifica l'intervallo predefinito
                                                                quando il valore non è valido.

  `testFetchEventsThrowsDecodingErrorForInvalidJSON`            Verifica la gestione di JSON non
                                                                decodificabile.

  `testFetchEventsThrowsHTTPError`                              Verifica la gestione degli errori
                                                                HTTP.

  `testFetchEventsHandlesRateLimit429`                          Verifica il rate limit HTTP 429 e
                                                                l'header `Retry-After`.

  `testFetchEventsHandlesRateLimit403`                          Verifica il rate limit HTTP 403
                                                                tramite gli header di reset GitHub.
  -------------------------------------------------------------------------------------------------

## PollingServiceTests --- 5 test

  ----------------------------------------------------------------------------------------
  Metodo                                               Descrizione
  ---------------------------------------------------- -----------------------------------
  `testPollingExecutesOperationAfterInitialInterval`   Verifica l'esecuzione dopo
                                                       l'intervallo iniziale.

  `testPollingStopsExecutingAfterStop`                 Verifica l'interruzione del polling
                                                       con `stop()`.

  `testPollingUsesUpdatedInterval`                     Verifica l'applicazione del nuovo
                                                       intervallo ai cicli successivi.

  `testPollingUsesMinimumIntervalOfOneSecond`          Verifica il rispetto
                                                       dell'intervallo minimo di un
                                                       secondo.

  `testStartingPollingAgainStopsPreviousPolling`       Verifica che un nuovo avvio
                                                       interrompa il polling precedente.
  ----------------------------------------------------------------------------------------

## AvatarLoaderTests --- 6 test

  --------------------------------------------------------------------------------------
  Metodo                                             Descrizione
  -------------------------------------------------- -----------------------------------
  `testLoadImageReturnsImageForSuccessfulResponse`   Verifica il download e la
                                                     conversione di un'immagine valida
                                                     in `UIImage`.

  `testLoadImageUsesCacheForRepeatedRequests`        Verifica il riutilizzo della cache
                                                     nelle richieste successive.

  `testLoadImageSharesConcurrentRequests`            Verifica la condivisione di
                                                     richieste simultanee per lo stesso
                                                     URL.

  `testLoadImageReturnsNilForHTTPError`              Verifica che una risposta HTTP non
                                                     valida non restituisca un'immagine.

  `testLoadImageReturnsNilForInvalidImageData`       Verifica la gestione di dati
                                                     immagine non validi.

  `testLoadImageReturnsNilForNetworkError`           Verifica la gestione degli errori
                                                     di rete senza crash.
  --------------------------------------------------------------------------------------

## GitHubTokenStoreTests --- 5 test

  -----------------------------------------------------------------------------------
  Metodo                                          Descrizione
  ----------------------------------------------- -----------------------------------
  `testReadReturnsNilWhenTokenDoesNotExist`       Verifica che la lettura restituisca
                                                  `nil` se il token non esiste.

  `testSaveAndReadToken`                          Verifica il salvataggio e la
                                                  lettura del token.

  `testSaveUpdatesExistingToken`                  Verifica che un nuovo token
                                                  sostituisca quello precedente.

  `testDeleteRemovesToken`                        Verifica la rimozione del token dal
                                                  Keychain.

  `testDeleteDoesNotThrowWhenTokenDoesNotExist`   Verifica che la cancellazione
                                                  ripetuta non generi errori.
  -----------------------------------------------------------------------------------

## EventDetailViewModelTests --- 5 test

  -----------------------------------------------------------------------------------
  Metodo                                          Descrizione
  ----------------------------------------------- -----------------------------------
  `testInitializationMapsEventProperties`         Verifica il mapping delle proprietà
                                                  generali dell'evento.

  `testWatchEventMapsAction`                      Verifica l'estrazione dell'azione
                                                  di un Watch Event.

  `testPushEventMapsBranchAndCommitInformation`   Verifica l'estrazione di branch,
                                                  Push ID e identificativi dei
                                                  commit.

  `testUnknownPayloadMapsAvailableValues`         Verifica il mapping dei campi
                                                  disponibili in un payload
                                                  sconosciuto.

  `testEmptyPayloadReturnsNoSections`             Verifica che un payload sconosciuto
                                                  vuoto non generi sezioni.
  -----------------------------------------------------------------------------------

## Esecuzione dei test

1.  Aprire il progetto in Xcode.
2.  Selezionare lo schema dell'applicazione.
3.  Eseguire `Command + U` oppure **Product → Test**.
4.  Consultare il Test Navigator.

## Riepilogo

  Suite                             Test
  ----------------------------- --------
  `MergeEventsUseCaseTests`            5
  `FilterEventsUseCaseTests`           5
  `EventsRepositoryTests`              5
  `EventsViewModelTests`               9
  `GitHubAPIClientTests`               9
  `PollingServiceTests`                5
  `AvatarLoaderTests`                  6
  `GitHubTokenStoreTests`              5
  `EventDetailViewModelTests`          5
  **Totale**                      **54**
