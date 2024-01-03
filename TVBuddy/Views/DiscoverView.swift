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
        let _ = Self._printChanges()
        
        ScrollView(.vertical, showsIndicators: false) {
            MediaCarousel()

            VStack(spacing: 10) {
                PageableMovieList(title: "Trending Movies", fetchMethod: MovieStore.shared.trending)
                PageableTVShowList(title: "Trending TV Shows", fetchMethod: TVStore.shared.trending)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Discover")
    }
}
