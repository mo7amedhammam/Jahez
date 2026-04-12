//
//  MoviesListViewModel.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import Foundation
import Combine

@MainActor
class MoviesListViewModel: ObservableObject {

    @Published var movies: [Movie] = []
    @Published var genres: [Genre] = []
    @Published var searchText = ""
    @Published var selectedGenreID: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: MoviesRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: MoviesRepository) {
        self.repository = repository
    }

    var filteredMovies: [Movie] {
        movies.filter { movie in
            let matchesSearch = searchText.isEmpty || movie.title.localizedCaseInsensitiveContains(searchText)
            let matchesGenre = selectedGenreID == nil || movie.genreIds.contains(selectedGenreID ?? -1)
            return matchesSearch && matchesGenre
        }
    }

    func loadMovies() {
        isLoading = true
        errorMessage = nil

        Publishers.Zip(
            repository.fetchMovies(page: 1),
            repository.fetchGenres()
        )
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false

                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { movies, genres in
                self.movies = movies
                self.genres = genres
            }
            .store(in: &cancellables)
    }

    func toggleGenre(_ genreID: Int) {
        if selectedGenreID == genreID {
            selectedGenreID = nil
        } else {
            selectedGenreID = genreID
        }
    }
}
