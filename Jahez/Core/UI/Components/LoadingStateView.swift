//
//  LoadingStateView.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import SwiftUI

struct LoadingStateView: View {

    let message: String

    init(message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct LoadingStateModifier: ViewModifier {

    let isLoading: Bool
    let message: String

    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isLoading ? 0 : 1)

            if isLoading {
                LoadingStateView(message: message)
            }
        }
    }
}

extension View {
    func loadingStateView(
        isLoading: Bool,
        message: String = "Loading..."
    ) -> some View {
        modifier(
            LoadingStateModifier(
                isLoading: isLoading,
                message: message
            )
        )
    }
}

#Preview {
    LoadingStateView(message: "Fetching movies...")
}
