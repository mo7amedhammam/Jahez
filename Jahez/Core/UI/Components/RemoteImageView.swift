//
//  RemoteImageView.swift
//  Jahez
//
//  Created by mohamed hammam on 12/04/2026.
//
import Kingfisher
import SwiftUI

struct RemoteImageView: View {
    
    let urlString: String?
    var contentMode: SwiftUI.ContentMode = .fill
    var cornerRadius: CGFloat = 0
    
    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            KFImage(url)
                .placeholder {
                    Color.white.opacity(0.08)
                }
                .retry(maxCount: 2, interval: .seconds(2))
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            Color.white.opacity(0.08)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
