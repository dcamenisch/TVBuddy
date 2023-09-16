//
//  DiscoverView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI
import TMDb

struct DiscoverView: View {
    @EnvironmentObject private var tvStore: TVStore
    @EnvironmentObject private var movieStore: MovieStore
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            MediaCarousel()
            
            VStack(spacing: 10) {
                MediaList(movies: movieStore.trending(), title: "Trending Movies")
                MediaList(shows: tvStore.trending(), title: "Trending TV Shows")
            }
            .padding(.horizontal)
            
        }.navigationTitle("Discover")
    }
}

#Preview {
    DiscoverView()
}
