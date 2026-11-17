# GitHub Events -- Test Documentation

**Framework:** XCTest · **Language:** Swift · **Test suites:** 9 ·
**Documented tests:** 54

## Introduction

This document describes the automated test suite of the GitHub Events
project. The suite validates application logic, GitHub event handling,
HTTP requests, polling, image caching, and Keychain-based
authentication. Tests use XCTest and, where required, custom mocks and
`URLProtocol` implementations.

## MergeEventsUseCaseTests --- 5 tests

  --------------------------------------------------------------------------------------
  Method                                             Description
  -------------------------------------------------- -----------------------------------
  `testExecuteMergesExistingAndIncomingEvents`       Ensures two event lists are
                                                     correctly merged.

  `testExecuteRemovesDuplicateEvents`                Ensures events with duplicate
                                                     identifiers are removed.

  `testExecuteIncomingEventOverridesExistingEvent`   Ensures an incoming event replaces
                                                     the previously stored event.

  `testExecuteSortsEventsByDateDescending`           Ensures events are sorted from
                                                     newest to oldest.

  `testExecuteReturnsEmptyArrayWhenInputsAreEmpty`   Validates behavior with empty input
                                                     lists.
  --------------------------------------------------------------------------------------

## FilterEventsUseCaseTests --- 5 tests

  -------------------------------------------------------------------------------------------
  Method                                                  Description
  ------------------------------------------------------- -----------------------------------
  `testExecuteReturnsAllEventsWhenNoFiltersAreSelected`   Ensures all events are returned
                                                          when no filters are selected.

  `testExecuteFiltersEventsBySingleType`                  Validates filtering by a single
                                                          event type.

  `testExecuteFiltersEventsByMultipleTypes`               Validates filtering by multiple
                                                          event types.

  `testExecuteReturnsEmptyArrayWhenNoEventsMatch`         Ensures an empty result is returned
                                                          when no event matches the filters.

  `testExecuteReturnsEmptyArrayWhenInputIsEmpty`          Validates behavior with an empty
                                                          input list.
  -------------------------------------------------------------------------------------------

## EventsRepositoryTests --- 5 tests

  ------------------------------------------------------------------------------------------
  Method                                                 Description
  ------------------------------------------------------ -----------------------------------
  `testFetchEventsStoresInitialEvents`                   Ensures initial events are
                                                         correctly fetched and stored.

  `testFetchEventsMergesNewEventsAndRemovesDuplicates`   Validates event merging and
                                                         deduplication.

  `testFetchEventsKeepsCacheWhenResponseIsNotModified`   Ensures cached data is preserved
                                                         when the server returns HTTP 304.

  `testFetchEventsPreservesAndUpdatesETag`               Validates ETag updates and
                                                         preservation.

  `testFetchEventsPropagatesAPIError`                    Ensures API client errors are
                                                         correctly propagated.
  ------------------------------------------------------------------------------------------

## EventsViewModelTests --- 9 tests

  -----------------------------------------------------------------------------------------------
  Method                                                      Description
  ----------------------------------------------------------- -----------------------------------
  `testLoadEventsUpdatesViewModelState`                       Ensures loading events correctly
                                                              updates the ViewModel state.

  `testLoadEventsHandlesEmptyResponse`                        Validates handling of a successful
                                                              response containing no events.

  `testUpdateFiltersReturnsOnlySelectedEventTypes`            Ensures only events matching
                                                              selected filters are displayed.

  `testUpdateFiltersWithEmptySelectionReturnsAllEvents`       Ensures clearing filters restores
                                                              all events.

  `testLoadEventsHandlesNetworkError`                         Validates network error handling.

  `testLoadEventsUpdatesAvailableEventTypes`                  Ensures the ViewModel exposes the
                                                              available event types.

  `testLoadEventsHandlesRateLimitWithResetDate`               Validates rate limit handling when
                                                              a reset date is available.

  `testLoadEventsHandlesRateLimitWithoutResetDate`            Validates rate limit handling when
                                                              no reset date is available.

  `testLoadEventsPreservesPreviouslyLoadedEventsAfterError`   Ensures previously loaded events
                                                              remain available after a subsequent
                                                              request fails.
  -----------------------------------------------------------------------------------------------

## GitHubAPIClientTests --- 9 tests

  -------------------------------------------------------------------------------------------------
  Method                                                        Description
  ------------------------------------------------------------- -----------------------------------
  `testFetchEventsReturnsEventsOnHTTP200`                       Validates event decoding for an
                                                                HTTP 200 response.

  `testFetchEventsReturnsNotModifiedOnHTTP304`                  Validates Not Modified response
                                                                handling.

  `testFetchEventsSendsETagHeader`                              Ensures the ETag is sent in the
                                                                `If-None-Match` header.

  `testFetchEventsUsesDefaultPollIntervalWhenHeaderIsMissing`   Validates the default interval when
                                                                the header is missing.

  `testFetchEventsUsesDefaultPollIntervalWhenHeaderIsInvalid`   Validates the default interval when
                                                                the received value is invalid.

  `testFetchEventsThrowsDecodingErrorForInvalidJSON`            Validates handling of undecodable
                                                                JSON.

  `testFetchEventsThrowsHTTPError`                              Validates HTTP error handling.

  `testFetchEventsHandlesRateLimit429`                          Validates HTTP 429 rate limit
                                                                handling and the `Retry-After`
                                                                header.

  `testFetchEventsHandlesRateLimit403`                          Validates HTTP 403 rate limit
                                                                handling using GitHub reset
                                                                headers.
  -------------------------------------------------------------------------------------------------

## PollingServiceTests --- 5 tests

  ----------------------------------------------------------------------------------------
  Method                                               Description
  ---------------------------------------------------- -----------------------------------
  `testPollingExecutesOperationAfterInitialInterval`   Ensures the operation executes
                                                       after the initial interval.

  `testPollingStopsExecutingAfterStop`                 Ensures polling stops when `stop()`
                                                       is called.

  `testPollingUsesUpdatedInterval`                     Ensures an updated interval is
                                                       applied to subsequent cycles.

  `testPollingUsesMinimumIntervalOfOneSecond`          Ensures the minimum one-second
                                                       interval is respected.

  `testStartingPollingAgainStopsPreviousPolling`       Ensures starting polling again
                                                       stops the previous task.
  ----------------------------------------------------------------------------------------

## AvatarLoaderTests --- 6 tests

  --------------------------------------------------------------------------------------
  Method                                             Description
  -------------------------------------------------- -----------------------------------
  `testLoadImageReturnsImageForSuccessfulResponse`   Ensures a valid image is downloaded
                                                     and converted into `UIImage`.

  `testLoadImageUsesCacheForRepeatedRequests`        Ensures subsequent requests reuse
                                                     the image cache.

  `testLoadImageSharesConcurrentRequests`            Ensures concurrent requests for the
                                                     same URL share one loading
                                                     operation.

  `testLoadImageReturnsNilForHTTPError`              Ensures an invalid HTTP response
                                                     does not return an image.

  `testLoadImageReturnsNilForInvalidImageData`       Validates handling of invalid image
                                                     data.

  `testLoadImageReturnsNilForNetworkError`           Validates network error handling
                                                     without an application crash.
  --------------------------------------------------------------------------------------

## GitHubTokenStoreTests --- 5 tests

  -----------------------------------------------------------------------------------
  Method                                          Description
  ----------------------------------------------- -----------------------------------
  `testReadReturnsNilWhenTokenDoesNotExist`       Ensures reading returns `nil` when
                                                  no token exists.

  `testSaveAndReadToken`                          Validates saving and reading a
                                                  token.

  `testSaveUpdatesExistingToken`                  Ensures a new token replaces the
                                                  previously stored token.

  `testDeleteRemovesToken`                        Ensures the token is removed from
                                                  the Keychain.

  `testDeleteDoesNotThrowWhenTokenDoesNotExist`   Ensures repeated deletion does not
                                                  throw an error.
  -----------------------------------------------------------------------------------

## EventDetailViewModelTests --- 5 tests

  -----------------------------------------------------------------------------------
  Method                                          Description
  ----------------------------------------------- -----------------------------------
  `testInitializationMapsEventProperties`         Validates mapping of the event's
                                                  general properties.

  `testWatchEventMapsAction`                      Validates extraction of a Watch
                                                  Event action.

  `testPushEventMapsBranchAndCommitInformation`   Validates extraction of the branch,
                                                  Push ID, and commit identifiers.

  `testUnknownPayloadMapsAvailableValues`         Validates mapping of available
                                                  fields from an unknown payload.

  `testEmptyPayloadReturnsNoSections`             Ensures an empty unknown payload
                                                  does not generate sections.
  -----------------------------------------------------------------------------------

## Running the tests

1.  Open the project in Xcode.
2.  Select the application scheme.
3.  Press `Command + U` or choose **Product → Test**.
4.  Inspect the results in the Test Navigator.

## Summary

  Test suite                       Tests
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
  **Total**                       **54**
