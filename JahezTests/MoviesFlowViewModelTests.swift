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
private func waitUntil(
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

private struct TimeoutError: Error {}


