//
//  MovieDetailsRepository.swift
//  Jahez
//
//  Created by mohamed hammam on 12/04/2026.
//

import Combine


//MARK: Domain Layer (Protocol)
protocol MovieDetailsRepository {
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error>
}

//MARK: Data Layer (Implementation)
class MovieDetailsRepositoryImpl: MovieDetailsRepository {

    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, Error> {
        APIClient.shared
            .request(MovieDetailsDTO.self, MoviesEndpoint.details(id: id))
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
}
