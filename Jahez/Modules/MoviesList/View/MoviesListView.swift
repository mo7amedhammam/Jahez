//
//  MoviesListView.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import SwiftUI

struct MoviesListView: View {

    @StateObject var viewModel: MoviesListViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                    VStack(alignment: .leading, spacing: 18) {
                        SearchHeader(
                            searchText: $viewModel.searchText,
                            selectedGenreName: selectedGenreName,
                            clearSelection: { viewModel.selectedGenreID = nil;viewModel.searchText = "" }
                        )

                        Text("Watch New Movies")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.yellow)
                            .padding(.horizontal, 16)

                        GenreFilterRow(
                            genres: viewModel.genres,
                            selectedGenreID: viewModel.selectedGenreID,
                            onTap: viewModel.toggleGenre(_:)
                        )
                        .zIndex(1)
                        
                        ScrollView(showsIndicators: false) {

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.filteredMovies, id: \.id) { movie in
                                NavigationLink {
                                    MovieDetailsView(
                                        viewModel: MovieDetailsViewModel(
                                            movieID: movie.id,
                                            repository: MovieDetailsRepositoryImpl()
                                        )
                                    )
                                } label: {
                                    MovieCardView(movie: movie)
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    viewModel.loadNextPageIfNeeded(currentMovie: movie)
                                }
                            }

                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .tint(.yellow)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .gridCellColumns(columns.count)
                            }
                        }
                        .zIndex(0)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .loadingStateView(
                    isLoading: viewModel.isLoading,
                    message: "Fetching movies..."
                )
                .errorStateView(
                    message: viewModel.errorMessage,
                    buttonAction: {
                        viewModel.loadMovies()
                    }
                )
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                if viewModel.movies.isEmpty {
                    viewModel.loadMovies()
                }
            }
        }
    }

    private var selectedGenreName: String? {
        guard let selectedGenreID = viewModel.selectedGenreID else {
            return nil
        }

        return viewModel.genres.first(where: { $0.id == selectedGenreID })?.name
    }
}

private struct SearchHeader: View {

    @Binding var searchText: String
    let selectedGenreName: String?
    let clearSelection: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Search TMDB", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)

            Button(action: clearSelection) {
                Image(systemName: selectedGenreName == nil ? "xmark" : "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

private struct GenreFilterRow: View {

    let genres: [Genre]
    let selectedGenreID: Int?
    let onTap: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(genres, id: \.id) { genre in
                    Button(action: { onTap(genre.id) }) {
                        Text(genre.name)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedGenreID == genre.id ? Color.yellow : Color.clear)
                            .foregroundStyle(selectedGenreID == genre.id ? .black : .white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow.opacity(0.85), lineWidth: 1)
                            }
                            .clipShape(Capsule())
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .contentShape(Rectangle())
        .padding(.bottom, 4)
    }
}

private struct MovieCardView: View {

    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: movie.posterURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    ZStack {
                        Color.white.opacity(0.08)
                        Image(systemName: "film")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 185)
            .clipShape(RoundedRectangle(cornerRadius: 0))

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(movie.year)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

#Preview {
    MoviesListView(
        viewModel: MoviesListViewModel(
            repository: MoviesRepositoryImpl()
        )
    )
}
