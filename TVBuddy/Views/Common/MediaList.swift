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
    
    var media = [Media]()
    
    init(
        title: String = "",
        movies: [Movie] = [],
        tvShows: [TVShow] = [],
        tmdbMovies: [TMDb.Movie] = [],
        tmdbTVShows: [TMDb.TVShow] = [],
        tmdbPerson: [TMDb.Person] = []
    ) {
        self.title = title
        
        media.append(contentsOf: movies.map({Media.movie($0)}))
        media.append(contentsOf: tvShows.map({Media.tvShow($0)}))
        
        media.append(contentsOf: tmdbMovies.map({Media.tmdbMovie($0)}))
        media.append(contentsOf: tmdbTVShows.map({Media.tmdbTVShow($0)}))
        media.append(contentsOf: tmdbPerson.map({Media.tmdbPerson($0)}))
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
        
    func mediaListItem(item: Media) -> some View {
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
    
    let mediaItem: Media
    
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
    
    let mediaItem: Media
    
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
    
    let mediaItem: Media
    
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
