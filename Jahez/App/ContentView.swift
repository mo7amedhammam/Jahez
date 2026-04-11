//
//  ContentView.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        MoviesListView(
            viewModel: MoviesListViewModel(
                repository: MoviesRepositoryImpl()
            )
        )
    }
}

#Preview {
    ContentView()
}
