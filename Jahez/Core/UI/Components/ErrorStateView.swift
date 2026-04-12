//
//  ErrorStateView.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import SwiftUI

struct ErrorStateView: View {

    let title: String?
    let message: String
    let buttonTitle: String
    let buttonAction: (() -> Void)?

    init(
        title: String? = nil,
        message: String,
        buttonTitle: String = "Try Again",
        buttonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    var body: some View {
        VStack(spacing: 16) {
            
            VStack(spacing: 8) {
                
                if let title = title {
                    Text(title)
                        .font(.headline)
                }
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }

            if let buttonAction {
                Button(buttonTitle, action: buttonAction)
                    .buttonStyle(.borderedProminent)
            }
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background{Color.black.opacity(0.4)}
        .cornerRadius(12)

    }
}

private struct ErrorStateModifier: ViewModifier {

    let title: String?
    let message: String?
    let buttonTitle: String
    let buttonAction: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(message == nil ? 1 : 0)

            if let message {
                ErrorStateView(
                    title: title,
                    message: message,
                    buttonTitle: buttonTitle,
                    buttonAction: buttonAction
                )
            }
        }
    }
}

extension View {
    func errorStateView(
        message: String?,
        title: String? = nil,
        buttonTitle: String = "Try Again",
        buttonAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            ErrorStateModifier(
                title: title,
                message: message,
                buttonTitle: buttonTitle,
                buttonAction: buttonAction
            )
        )
    }
}

#Preview {
    ErrorStateView(message: "Unable to fetch the movies list right now.") { }
}
