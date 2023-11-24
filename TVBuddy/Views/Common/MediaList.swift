//
//  MediaList.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MediaList: View {
    let title: String

    var media = [TVBuddyMediaItem]()

    init(
        title: String = "",
        movies: [TVBuddyMovie] = [],
        tvShows: [TVBuddyTVShow] = [],
        tmdbMovies: [Movie] = [],
        tmdbTVShows: [TVSeries] = [],
        tmdbPerson: [Person] = []
    ) {
        self.title = title

        media.append(contentsOf: movies.map { TVBuddyMediaItem.movie($0) })
        media.append(contentsOf: tvShows.map { TVBuddyMediaItem.tvShow($0) })

        media.append(contentsOf: tmdbMovies.map { TVBuddyMediaItem.tmdbMovie($0) })
        media.append(contentsOf: tmdbTVShows.map { TVBuddyMediaItem.tmdbTVShow($0) })
        media.append(contentsOf: tmdbPerson.map { TVBuddyMediaItem.tmdbPerson($0) })
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(media) { item in
                        mediaListItem(item: item)
                    }
                }
            }
        }
    }

    func mediaListItem(item: TVBuddyMediaItem) -> some View {
        switch item {
        case .movie:
            return AnyView(MediaListMovieItem(mediaItem: item))

        case .tvShow:
            return AnyView(MediaListTVShowItem(mediaItem: item))

        case .tmdbMovie:
            return AnyView(MediaListMovieItem(mediaItem: item))

        case .tmdbTVShow:
            return AnyView(MediaListTVShowItem(mediaItem: item))

        case .tmdbPerson:
            return AnyView(MediaListPersonItem(mediaItem: item))
        }
    }
}

struct MediaListMovieItem: View {
    @EnvironmentObject private var movieStore: MovieStore
    @State var poster: URL?

    let mediaItem: TVBuddyMediaItem

    var body: some View {
        NavigationLink {
            MovieView(id: mediaItem.id)
        } label: {
            ImageView(title: mediaItem.name, url: poster)
                .posterStyle(size: .small)
        }
        .task {
            poster = await movieStore.poster(withID: mediaItem.id)
        }
    }
}

struct MediaListTVShowItem: View {
    @EnvironmentObject private var tvStore: TVStore
    @State var poster: URL?

    let mediaItem: TVBuddyMediaItem

    var body: some View {
        NavigationLink {
            TVShowView(id: mediaItem.id)
        } label: {
            ImageView(title: mediaItem.name, url: poster)
                .posterStyle(size: .small)
        }
        .task {
            poster = await tvStore.poster(withID: mediaItem.id)
        }
    }
}

struct MediaListPersonItem: View {
    @EnvironmentObject private var personStore: PersonStore
    @State var poster: URL?

    let mediaItem: TVBuddyMediaItem

    var body: some View {
        NavigationLink {
            Text(mediaItem.name)
        } label: {
            ImageView(title: mediaItem.name, url: poster)
                .posterStyle(size: .small)
        }
        .task {
            poster = await personStore.image(forPerson: mediaItem.id)
        }
    }
}
