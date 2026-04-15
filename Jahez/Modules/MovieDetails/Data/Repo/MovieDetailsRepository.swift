//
//  MovieDetailsRepository.swift
//  Jahez
//
//  Created by mohamed hammam on 12/04/2026.
//

import Combine
import Foundation


//MARK: Domain Layer (Protocol)
protocol MovieDetailsRepository {
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error>
}

//MARK: Data Layer (Implementation)
class MovieDetailsRepositoryImpl: MovieDetailsRepository {

    private let cacheStore: MovieDetailsCacheStore

    init(cacheStore: MovieDetailsCacheStore = MovieDetailsCacheStore()) {
        self.cacheStore = cacheStore
    }

    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        APIClient.shared
            .request(MovieDetailsDTO.self, MoviesEndpoint.details(id: id))
            .map { $0.toDomain() }
            .handleEvents(receiveOutput: { [cacheStore] movie in
                cacheStore.save(movie)
            })
            .catch { [cacheStore] error -> AnyPublisher<MovieDetails, Error> in
                guard let cachedMovie = cacheStore.loadMovie(id: id) else {
                    return Fail(error: error).eraseToAnyPublisher()
                }

                return Just(cachedMovie)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

final class MovieDetailsCacheStore {

    private let cacheStore: RealmCacheStore

    init(cacheStore: RealmCacheStore = RealmCacheStore()) {
        self.cacheStore = cacheStore
    }

    func save(_ movie: MovieDetails) {
        cacheStore.save(movie, forKey: cacheKey(for: movie.id))
    }

    func loadMovie(id: Int) -> MovieDetails? {
        return cacheStore.load(MovieDetails.self, forKey: cacheKey(for: id))
    }

    private func cacheKey(for movieID: Int) -> String {
        "movie.details.\(movieID)"
    }
}
