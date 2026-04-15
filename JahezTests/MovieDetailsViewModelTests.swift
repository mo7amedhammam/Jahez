//
//  MovieDetailsViewModelTests.swift
//  Jahez
//
//  Created by mohamed hammam on 15/04/2026.
//

import Combine
import Foundation
import Testing
@testable import Jahez

@MainActor
struct MovieDetailsViewModelTests {

    @Test
    func loadMovieDetailsStoresMovieOnSuccess() async throws {
        let expectedMovie = MovieDetails(
            id: 42,
            title: "Interstellar",
            overview: "A team travels through a wormhole.",
            runtime: 169,
            releaseDate: "2014-11-07",
            genres: [Genre(id: 10, name: "Sci-Fi")],
            posterPath: nil,
            backdropPath: nil,
            status: "Released",
            tagline: "Mankind was born on Earth. It was never meant to die here.",
            homepage: "",
            budget: 100,
            revenue: 200,
            languages: ["English"]
        )
        let repository = MockMovieDetailsRepository(results: [42: .success(expectedMovie)])
        let viewModel = MovieDetailsViewModel(movieID: 42, repository: repository)

        viewModel.loadMovieDetails()
        try await waitUntil { viewModel.movie == expectedMovie && !viewModel.isLoading }

        #expect(viewModel.movie == expectedMovie)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.shouldShowOfflineAlert == false)
        #expect(repository.requestedIDs == [42])
    }

    @Test
    func loadMovieDetailsShowsOfflineAlertForNoConnection() async throws {
        let repository = MockMovieDetailsRepository(
            results: [7: .failure(NetworkError.noConnection)]
        )
        let viewModel = MovieDetailsViewModel(movieID: 7, repository: repository)

        viewModel.loadMovieDetails()
        try await waitUntil { viewModel.errorMessage == NetworkError.noConnection.localizedDescription && !viewModel.isLoading }

        #expect(viewModel.movie == nil)
        #expect(viewModel.shouldShowOfflineAlert)
        #expect(viewModel.errorMessage == "no_connection")
    }
}


private final class MockMovieDetailsRepository: MovieDetailsRepository {
    private let results: [Int: Result<MovieDetails, Error>]

    private(set) var requestedIDs: [Int] = []

    init(results: [Int: Result<MovieDetails, Error>]) {
        self.results = results
    }

    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        requestedIDs.append(id)
        let result = results[id] ?? .failure(NetworkError.apiError(code: 404, error: "Missing movie"))
        return result.publisher.eraseToAnyPublisher()
    }
}

@MainActor
 func waitUntil(
    timeoutNanoseconds: UInt64 = 1_000_000_000,
    condition: @escaping @MainActor () -> Bool
) async throws {
    let start = ContinuousClock.now
    let timeout = Duration.nanoseconds(Int64(timeoutNanoseconds))

    while !condition() {
        if ContinuousClock.now - start > timeout {
            throw TimeoutError()
        }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
}
 struct TimeoutError: Error {}


