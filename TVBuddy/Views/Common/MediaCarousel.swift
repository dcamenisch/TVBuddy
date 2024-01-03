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
    @StateObject var page: Page = .first()
    @State var trendingMedia = [Media]()
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        let _ = Self._printChanges()
        
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
                .onReceive(timer) { _ in
                    withAnimation {
                        page.update(.next)
                    }
                }
            
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
        .task(id: trendingMedia) {
            if trendingMedia.isEmpty {
                let trendingMovies = await MovieStore.shared.trending().prefix(6)
                let trendingTVShows = await TVStore.shared.trending().prefix(6)

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
    @State var backdropWithText: URL?

    let media: Media

    var body: some View {
        switch media {
        case let .movie(movie):
            NavigationLink {
                MovieView(id: movie.id)
            } label: {
                ImageView(title: movie.title, url: backdropWithText)
                    .backdropStyle()
                    .padding(5)
            }
            .buttonStyle(.plain)
            .task {
                backdropWithText = await MovieStore.shared.backdropWithText(withID: movie.id)
            }
        case let .tvSeries(tvSeries):
            NavigationLink {
                TVShowView(id: tvSeries.id)
            } label: {
                ImageView(title: tvSeries.name, url: backdropWithText)
                    .backdropStyle()
                    .padding(5)
            }
            .buttonStyle(.plain)
            .task {
                backdropWithText = await TVStore.shared.backdropWithText(withID: tvSeries.id)
            }
        case .person:
            Group {}
        }
    }
}
