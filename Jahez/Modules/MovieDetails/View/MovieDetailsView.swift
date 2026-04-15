//
//  MovieDetailsView.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import SwiftUI

struct MovieDetailsView: View {

    @StateObject var viewModel: MovieDetailsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                content()
                    .loadingStateView(
                        isLoading: viewModel.isLoading,
                        message: "Fetching movie details..."
                    )
                    .errorStateView(
                        message: viewModel.errorMessage,
                        buttonAction: {
                            viewModel.loadMovieDetails()
                        }
                    )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if viewModel.movie == nil {
                viewModel.loadMovieDetails()
            }
        }
    }

    @ViewBuilder
    private func content() -> some View {
        if let movie = viewModel.movie {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .top) {
                        RemoteImageView(
                            urlString: movie.backdropPath ?? movie.posterPath,
                            contentMode: SwiftUI.ContentMode.fill
                        )
                        .frame(height: 330)
                        .clipped()
                        .overlay {
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.15),
                                    Color.black.opacity(0.65),
                                    Color.black
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }

                        topBar()
                    }

                    detailsSection(movie)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                }
            }
        } else {
            Color.clear
        }
    }

    private func topBar() -> some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }

            Spacer()

        }
        .padding(.horizontal, 16)
        .padding(.top,16)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func detailsSection(_ movie: MovieDetails) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteImageView(
                urlString: movie.posterPath,
                contentMode: SwiftUI.ContentMode.fill
            )
            .frame(width: 72, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(titleText(for: movie))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(genreText(for: movie))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.78))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !movie.tagline.isEmpty {
                    Text(movie.tagline)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.68))
                        .italic()
                }
            }
        }

        Text(movie.overview)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white)
            .padding(.top, 18)

        VStack(alignment: .leading, spacing: 12) {
            if !movie.homepage.isEmpty, let homepageURL = URL(string: movie.homepage) {
                HStack(alignment: .top) {
                    Text("Homepage:")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Link(movie.homepage, destination: homepageURL)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.cyan)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            HStack(alignment: .top, spacing: 20) {
                metadataItem(title: "Languages:", value: languageText(for: movie))
                metadataItem(title: "Runtime:", value: "\(movie.runtime) minutes")
            }

            HStack(alignment: .top, spacing: 20) {
                metadataItem(title: "Status:", value: movie.status)
                metadataItem(title: "Budget:", value: currencyText(for: movie.budget))
            }

            HStack(alignment: .top, spacing: 20) {
                metadataItem(title: "Revenue:", value: currencyText(for: movie.revenue))
                Spacer(minLength: 0)
            }
        }
        .padding(.top, 22)
    }

    private func titleText(for movie: MovieDetails) -> String {
        let year = movie.releaseDate.prefix(4)
        if year.isEmpty {
            return movie.title
        }
        return "\(movie.title) (\(year))"
    }

    private func genreText(for movie: MovieDetails) -> String {
        movie.genres.map(\.name).joined(separator: ", ")
    }

    private func languageText(for movie: MovieDetails) -> String {
        let languages = movie.languages.filter { !$0.isEmpty }
        return languages.isEmpty ? "-" : languages.joined(separator: ", ")
    }

    private func currencyText(for amount: Int) -> String {
        guard amount > 0 else {
            return "-"
        }

        return "\(amount) $"
    }

    private func metadataItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)

            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MovieDetailsView(
        viewModel: MovieDetailsViewModel(
            movieID: 878,
            repository: MovieDetailsRepositoryImpl()
        )
    )
}
