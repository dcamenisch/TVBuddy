//
//  DiscoverView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI
import TMDb

struct DiscoverView: View {
    var body: some View {        
        ScrollView(.vertical, showsIndicators: false) {
            MediaCarousel()

            VStack(spacing: 10) {
                MediaCollection(title: "Trending Movies", fetchMethod: MovieStore.shared.trending, posterSize: .medium)
                MediaCollection(title: "Trending TV Shows", fetchMethod: TVStore.shared.trending, posterSize: .medium)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Discover")
    }
}
