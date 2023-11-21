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
                FetchableTVShowList(title: "Discover TV Shows", fetch: tvStore.discover)
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

struct FetchableTVShowList: View {
    let title: String
    let fetch: (Bool) async -> [TVSeries]
    
    @State var tvSeries = [TVSeries]()
    
    var body: some View {
        VStack(alignment: .leading) {
            if !title.isEmpty {
                Text(title)
                    .font(.title2)
                    .bold()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(tvSeries.indices, id: \.self) { i in
                        TVShowItem(tvSeries: tvSeries[i])
                            .onAppear(perform: {
                                if tvSeries.endIndex - AppConstants.nextPageOffset == i {
                                    Task {
                                        tvSeries = await fetch(true)
                                    }
                                }
                            })
                    }
                }
            }
        }
        .task {
            tvSeries = await fetch(false)
        }
    }
}

struct TVShowItem: View {
    @EnvironmentObject private var tvStore: TVStore
    @State var poster: URL?

    let tvSeries: TVSeries

    var body: some View {
        NavigationLink {
            TVShowView(id: tvSeries.id)
        } label: {
            ImageView(title: tvSeries.name, url: poster)
                .posterStyle(size: .small)
        }
        .task {
            poster = await tvStore.poster(withID: tvSeries.id)
        }
    }
}

