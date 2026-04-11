//
//  MoviesListViewModel.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import Foundation
import Combine

class MoviesListViewModel: ObservableObject {
    
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: MoviesRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: MoviesRepository) {
        self.repository = repository
    }
    
    func loadMovies() {
        isLoading = true
        
        repository.fetchMovies(page: 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
                
            } receiveValue: { movies in
                self.movies = movies
            }
            .store(in: &cancellables)
    }
}
