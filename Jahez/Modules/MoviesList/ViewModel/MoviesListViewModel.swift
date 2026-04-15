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
    @Published var isLoadingMore = false
    @Published var errorMessage: String?

    private let repository: MoviesRepository
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var totalPages = 1

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
        currentPage = 0
        totalPages = 1
        movies = []
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
            } receiveValue: { moviesPage, genres in
                self.currentPage = moviesPage.page
                self.totalPages = moviesPage.totalPages
                self.movies = moviesPage.movies
                self.genres = genres
            }
            .store(in: &cancellables)
    }

    func loadNextPageIfNeeded(currentMovie: Movie) {
        guard shouldLoadNextPage(after: currentMovie) else {
            return
        }

        isLoadingMore = true

        repository.fetchMovies(page: currentPage + 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoadingMore = false

                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { moviesPage in
                self.currentPage = moviesPage.page
                self.totalPages = moviesPage.totalPages

                let existingIDs = Set(self.movies.map(\.id))
                let newMovies = moviesPage.movies.filter { !existingIDs.contains($0.id) }
                self.movies.append(contentsOf: newMovies)
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

    private func shouldLoadNextPage(after movie: Movie) -> Bool {
        guard !isLoading,
              !isLoadingMore,
              searchText.isEmpty,
              selectedGenreID == nil,
              currentPage < totalPages else {
            return false
        }

        let thresholdIndex = max(movies.count - 6, 0)
        guard let currentIndex = movies.firstIndex(where: { $0.id == movie.id }) else {
            return false
        }

        return currentIndex >= thresholdIndex
    }
}
