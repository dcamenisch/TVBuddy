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

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            MediaCarousel(trendingMovies: trendingMovies)

            VStack(spacing: 10) {
                PageableMovieList(title: "Trending Movies", fetchMethod: movieStore.trending)
                PageableTVShowList(title: "Trending TV Shows", fetchMethod: tvStore.trending)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Discover")
        .task {
            trendingMovies = await movieStore.trending()
        }
    }
}
