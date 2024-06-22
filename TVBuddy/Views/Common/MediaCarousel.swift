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
    @State var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

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
                .cornerRadius(15)
                .padding(5)
            }
        }
        .onAppear(perform: {
            timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        })
        .onDisappear(perform: {
            timer.upstream.connect().cancel()
        })
        .task {
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
    @State var url: URL?

    let media: Media

    var body: some View {
        switch media {
        case let .movie(movie):
            NavigationLink {
                MovieView(id: movie.id)
            } label: {
                ImageView(url: url, placeholder: movie.title)
                    .cornerRadius(15)
                    .padding(5)
            }
            .buttonStyle(.plain)
            .task {
                url = await MovieStore.shared.backdropsWithText(withID: movie.id).first
            }
        case let .tvSeries(tvSeries):
            NavigationLink {
                TVShowView(id: tvSeries.id)
            } label: {
                ImageView(url: url, placeholder: tvSeries.name)
                    .cornerRadius(15)
                    .padding(5)
            }
            .buttonStyle(.plain)
            .task {
                url = await TVStore.shared.backdropsWithText(id: tvSeries.id).first
            }
        case .person:
            Group {}
        }
    }
}
