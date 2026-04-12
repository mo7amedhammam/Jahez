//
//  MovieDetailsViewModel.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import Foundation
import Combine

@MainActor
final class MovieDetailsViewModel: ObservableObject {

    @Published var movie: MovieDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let movieID: Int
    private let repository: MovieDetailsRepository
    private var cancellables = Set<AnyCancellable>()

    init(movieID: Int, repository: MovieDetailsRepository) {
        self.movieID = movieID
        self.repository = repository
    }

    func loadMovieDetails() {
        isLoading = true
        errorMessage = nil

        repository.fetchMovieDetails(id: movieID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false

                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { movie in
                self.movie = movie
            }
            .store(in: &cancellables)
    }
}
