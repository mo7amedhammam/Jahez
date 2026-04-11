//
//  MoviesRepository.swift
//  Jahez
//
//  Created by mohamed hammam on 11/04/2026.
//
import Combine

// Domain Layer (Protocol)
protocol MoviesRepository {
    func fetchMovies(page: Int) -> AnyPublisher<[Movie], Error>
}

//MARK: Data Layer (Implementation)
class MoviesRepositoryImpl: MoviesRepository {
    
    func fetchMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        APIClient.shared
            .request(MoviesResponseDTO.self,
                     MoviesEndpoint.trending(page: page))
            .map { response in
                response.results.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
}
