//
//  ImageView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import NukeUI
import SwiftUI

struct ImageView: View {
    let title: String
    let url: URL?

    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle().overlay(
                    Text(title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                )
                .foregroundColor(.secondary)
            }
        }
    }
}
