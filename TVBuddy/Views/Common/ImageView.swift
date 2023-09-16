//
//  ImageView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI
import NukeUI

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
                .foregroundColor(.gray)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ImageView(title: "Ashoka", url: URL(string: "https://www.themoviedb.org/t/p/original/laCJxobHoPVaLQTKxc14Y2zV64J.jpg"))
        .posterStyle(size: .large)
}
