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
    @State var trendingMedia = [TMDbMedia]()
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
                PlaceholderView()
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .task {
            await loadTrendingMedia()
        }
    }

    // Helper function to load trending media
    private func loadTrendingMedia() async {
        if trendingMedia.isEmpty {
            async let trendingMovies = MovieStore.shared.trending()
            async let trendingTVShows = TVStore.shared.trending()

            let movies = await trendingMovies.prefix(6).map(TMDbMedia.movie)
            let tvShows = await trendingTVShows.prefix(6).map(TMDbMedia.tvSeries)

            trendingMedia = (movies + tvShows).shuffled()
        }
    }

    // Helper functions for timer management
    private func startTimer() {
        timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    }

    private func stopTimer() {
        timer.upstream.connect().cancel()
    }
}

enum TMDbMedia: Identifiable, Equatable {
    case movie(Movie)
    case tvSeries(TVSeries)

    // Prefix with "movie-" or "tv-" to ensure uniqueness
    var id: String {
        switch self {
        case .movie(let movie):
            return "movie-\(movie.id)"
        case .tvSeries(let tvShow):
            return "tv-\(tvShow.id)"
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        Rectangle()
            .overlay(ProgressView())
            .foregroundColor(.secondary)
            .aspectRatio(1.77, contentMode: .fit)
            .cornerRadius(15)
            .padding(5)
    }
}

struct MediaCarouselItem: View {
    @State var url: URL?

    let media: TMDbMedia

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
        }
    }
}
