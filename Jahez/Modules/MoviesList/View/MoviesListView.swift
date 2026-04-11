//
//  MoviesListView.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import SwiftUI

struct MoviesListView: View {
    
    @StateObject var viewModel: MoviesListViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                } else {
                    List(viewModel.movies, id: \.id) { movie in
                        VStack(alignment: .leading) {
                            Text(movie.title)
                                .font(.headline)
                            
                            Text(movie.year)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .task{
                viewModel.loadMovies()
            }
        }
    }
}

#Preview {
    MoviesListView(
        viewModel: MoviesListViewModel(
            repository: MoviesRepositoryImpl()
        )
    )
}
