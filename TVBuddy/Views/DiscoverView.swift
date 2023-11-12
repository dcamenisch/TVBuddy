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
    
    @State var trendingMovies = [Movie]()
    @State var trendingTVShows = [TVSeries]()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {

            MediaCarousel(trendingMovies: trendingMovies)

            VStack(spacing: 10) {
                MediaList(title: "Trending Movies", tmdbMovies: trendingMovies)
                MediaList(title: "Trending TV Shows", tmdbTVShows: trendingTVShows)
            }
            .padding(.horizontal)

        }
        .navigationTitle("Discover")
        .task {
            trendingMovies = await movieStore.trending()
            trendingTVShows = await tvStore.trending()
        }
    }
}
