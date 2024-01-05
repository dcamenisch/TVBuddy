//
//  ImageView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import NukeUI
import SwiftUI

struct ImageView: View {
    let url: URL?
    let placeholder: String
    
    init(url: URL?, placeholder: String = "") {
        self.url = url
        self.placeholder = placeholder
    }

    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .overlay(
                        Text(placeholder)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                )
                .foregroundStyle(Color.background3)
            }
        }
    }
}
