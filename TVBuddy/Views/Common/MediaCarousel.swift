//
//  MediaCarousel.swift
//  TVBuddy
//
//  Created by Danny on 10.07.22.
//

import SwiftUI
import SwiftUIPager
import TMDb

struct MediaCarousel: View {
    @EnvironmentObject private var tvStore: TVStore
    @EnvironmentObject private var movieStore: MovieStore
    
    @StateObject var page: Page = .first()

    @State var trendingMedia = [Media]()

    var body: some View {
        Group {
            if !trendingMedia.isEmpty {
                Pager(page: page, data: trendingMedia) { media in
                    MediaCarouselItem(media: media)
                }
                .bounces(true)
                .interactive(scale: 0.95)
                .itemSpacing(20)
                .loopPages()
                .pagingPriority(.high)
                .aspectRatio(1.77, contentMode: .fit)
            } else {
                Rectangle().overlay(
                    ProgressView()
                )
                .foregroundColor(.secondary)
                .aspectRatio(1.77, contentMode: .fit)
                .backdropStyle()
                .padding(5)
            }
        }
        .task {
            if trendingMedia.isEmpty {
                let trendingMovies = await movieStore.trending().prefix(6)
                let trendingTVShows = await tvStore.trending().prefix(6)
                
                trendingMovies.forEach { movie in
                    trendingMedia.append(Media.movie(movie))
                }
                
                trendingTVShows.forEach { tvShow in
                    trendingMedia.append(Media.tvSeries(tvShow))
                }
                
                trendingMedia.shuffle()
            }
        }
    }
}

struct MediaCarouselItem: View {
    @EnvironmentObject private var tvStore: TVStore
    @EnvironmentObject private var movieStore: MovieStore
    
    @State var backdropWithText: URL?

    let media: Media
    
    var body: some View {
        switch media {
        case .movie(let movie):
            NavigationLink {
                MovieView(id: movie.id)
            } label: {
                ImageView(title: movie.title, url: backdropWithText)
                    .backdropStyle()
                    .padding(5)
            }
            .buttonStyle(.plain)
            .task {
                backdropWithText = await movieStore.backdropWithText(withID: movie.id)
            }
        case .tvSeries(let tvSeries):
            NavigationLink {
                TVShowView(id: tvSeries.id)
            } label: {
                ImageView(title: tvSeries.name, url: backdropWithText)
                    .backdropStyle()
                    .padding(5)
            }
            .buttonStyle(.plain)
            .task {
                backdropWithText = await tvStore.backdropWithText(withID: tvSeries.id)
            }
        case .person:
            Group {}
        }
    }
}
