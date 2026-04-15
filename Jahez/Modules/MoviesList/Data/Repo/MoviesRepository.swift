//
//  MoviesRepository.swift
//  Jahez
//
//  Created by mohamed hammam on 11/04/2026.
//
import Combine
import Foundation

//MARK: Domain Layer (Protocol)
protocol MoviesRepository {
    func fetchGenres() -> AnyPublisher<[Genre], Error>
    func fetchMovies(page: Int) -> AnyPublisher<MoviesPage, Error>
}

//MARK: Data Layer (Implementation)
class MoviesRepositoryImpl: MoviesRepository {

    private let cacheStore: MoviesCacheStore

    init(cacheStore: MoviesCacheStore = MoviesCacheStore()) {
        self.cacheStore = cacheStore
    }

    func fetchGenres() -> AnyPublisher<[Genre], Error> {
        APIClient.shared
            .request(GenresResponseDTO.self, MoviesEndpoint.genres)
            .map { response in
                response.genres.map { $0.toDomain() }
            }
            .handleEvents(receiveOutput: { [cacheStore] genres in
                cacheStore.saveGenres(genres)
            })
            .catch { [cacheStore] error -> AnyPublisher<[Genre], Error> in
                guard let cachedGenres = cacheStore.loadGenres(), !cachedGenres.isEmpty else {
                    return Fail(error: error).eraseToAnyPublisher()
                }

                return Just(cachedGenres)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func fetchMovies(page: Int) -> AnyPublisher<MoviesPage, Error> {
        APIClient.shared
            .request(MoviesResponseDTO.self,
                     MoviesEndpoint.trending(page: page))
            .map { $0.toDomain() }
            .handleEvents(receiveOutput: { [cacheStore] moviesPage in
                cacheStore.saveMoviesPage(moviesPage)
            })
            .catch { [cacheStore] error -> AnyPublisher<MoviesPage, Error> in
                guard let cachedPage = cacheStore.loadMoviesPage(page: page) else {
                    return Fail(error: error).eraseToAnyPublisher()
                }

                return Just(cachedPage)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

final class MoviesCacheStore {

    private enum CacheKeys {
        static let genres = "movies.list.genres"
        static let totalPages = "movies.list.totalPages"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveGenres(_ genres: [Genre]) {
        guard let data = try? encoder.encode(genres) else {
            return
        }

        defaults.set(data, forKey: CacheKeys.genres)
    }

    func loadGenres() -> [Genre]? {
        guard let data = defaults.data(forKey: CacheKeys.genres) else {
            return nil
        }

        return try? decoder.decode([Genre].self, from: data)
    }

    func saveMoviesPage(_ moviesPage: MoviesPage) {
        guard let data = try? encoder.encode(moviesPage.movies) else {
            return
        }

        defaults.set(data, forKey: moviesPageKey(for: moviesPage.page))
        defaults.set(moviesPage.totalPages, forKey: CacheKeys.totalPages)
    }

    func loadMoviesPage(page: Int) -> MoviesPage? {
        guard let data = defaults.data(forKey: moviesPageKey(for: page)),
              let movies = try? decoder.decode([Movie].self, from: data) else {
            return nil
        }

        let totalPages = defaults.integer(forKey: CacheKeys.totalPages)

        return MoviesPage(
            page: page,
            totalPages: max(totalPages, page),
            movies: movies
        )
    }

    private func moviesPageKey(for page: Int) -> String {
        "movies.list.page.\(page)"
    }
}
