//
//  MoviesListViewModelTests.swift
//  Jahez
//
//  Created by mohamed hammam on 15/04/2026.
//

import Combine
import Foundation
import Testing
@testable import Jahez

@MainActor
struct MoviesListViewModelTests {

    @Test
    func loadMoviesPopulatesMoviesAndGenres() async throws {
        let expectedMovies = [
            Movie(id: 1, title: "Dune", posterURL: nil, backdropURL: nil, year: "2024", rating: 8.7, genreIds: [10]),
            Movie(id: 2, title: "Arrival", posterURL: nil, backdropURL: nil, year: "2016", rating: 8.2, genreIds: [11])
        ]
        let expectedGenres = [
            Genre(id: 10, name: "Sci-Fi"),
            Genre(id: 11, name: "Drama")
        ]
        let repository = MockMoviesRepository(
            moviesPages: [
                1: .success(MoviesPage(page: 1, totalPages: 2, movies: expectedMovies))
            ],
            genresResult: .success(expectedGenres)
        )
        let viewModel = MoviesListViewModel(repository: repository)

        viewModel.loadMovies()
        try await waitUntil {
            viewModel.movies == expectedMovies && viewModel.genres == expectedGenres && !viewModel.isLoading
        }

        #expect(viewModel.movies == expectedMovies)
        #expect(viewModel.genres == expectedGenres)
        #expect(repository.requestedPages == [1])
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func filteredMoviesUsesSearchAndGenreSelection() {
        let repository = MockMoviesRepository(
            moviesPages: [:],
            genresResult: .success([])
        )
        let viewModel = MoviesListViewModel(repository: repository)
        viewModel.movies = [
            Movie(id: 1, title: "Dune", posterURL: nil, backdropURL: nil, year: "2024", rating: 8.7, genreIds: [10]),
            Movie(id: 2, title: "Arrival", posterURL: nil, backdropURL: nil, year: "2016", rating: 8.2, genreIds: [11]),
            Movie(id: 3, title: "Dune: Part Two", posterURL: nil, backdropURL: nil, year: "2024", rating: 8.9, genreIds: [10, 11])
        ]

        viewModel.searchText = "dune"
        #expect(viewModel.filteredMovies.map(\.id) == [1, 3])

        viewModel.toggleGenre(10)
        #expect(viewModel.selectedGenreID == 10)
        #expect(viewModel.filteredMovies.map(\.id) == [1, 3])

        viewModel.toggleGenre(10)
        #expect(viewModel.selectedGenreID == nil)
    }

    @Test
    func loadNextPageAppendsOnlyNewMovies() async throws {
        let firstPageMovies = (1...8).map {
            Movie(id: $0, title: "Movie \($0)", posterURL: nil, backdropURL: nil, year: "2024", rating: 7.0, genreIds: [10])
        }
        let secondPageMovies = [
            Movie(id: 8, title: "Movie 8", posterURL: nil, backdropURL: nil, year: "2024", rating: 7.0, genreIds: [10]),
            Movie(id: 9, title: "Movie 9", posterURL: nil, backdropURL: nil, year: "2024", rating: 7.5, genreIds: [10])
        ]
        let repository = MockMoviesRepository(
            moviesPages: [
                1: .success(MoviesPage(page: 1, totalPages: 2, movies: firstPageMovies)),
                2: .success(MoviesPage(page: 2, totalPages: 2, movies: secondPageMovies))
            ],
            genresResult: .success([Genre(id: 10, name: "Action")])
        )
        let viewModel = MoviesListViewModel(repository: repository)

        viewModel.loadMovies()
        try await waitUntil { viewModel.movies.count == firstPageMovies.count && !viewModel.isLoading }

        viewModel.loadNextPageIfNeeded(currentMovie: firstPageMovies[2])
        try await waitUntil { viewModel.movies.count == 9 && !viewModel.isLoadingMore }

        #expect(repository.requestedPages == [1, 2])
        #expect(viewModel.movies.map(\.id) == Array(1...9))
    }
}


private final class MockMoviesRepository: MoviesRepository {
    private let moviesPages: [Int: Result<MoviesPage, Error>]
    private let genresResult: Result<[Genre], Error>

    private(set) var requestedPages: [Int] = []

    init(moviesPages: [Int: Result<MoviesPage, Error>], genresResult: Result<[Genre], Error>) {
        self.moviesPages = moviesPages
        self.genresResult = genresResult
    }

    func fetchGenres() -> AnyPublisher<[Genre], Error> {
        genresResult.publisher.eraseToAnyPublisher()
    }

    func fetchMovies(page: Int) -> AnyPublisher<MoviesPage, Error> {
        requestedPages.append(page)
        let result = moviesPages[page] ?? .failure(NetworkError.apiError(code: 404, error: "Missing page"))
        return result.publisher.eraseToAnyPublisher()
    }
}
