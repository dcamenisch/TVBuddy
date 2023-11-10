//
//  MediaList.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MediaList: View {
    
    @EnvironmentObject private var movieStore: MovieStore
    @EnvironmentObject private var personStore: PersonStore
    @EnvironmentObject private var tvStore: TVStore
    
    var media: [TMDb.Media] {
        var result: [TMDb.Media] = []
        
        var tmpMovies = movies.compactMap { movieStore.movie(withID: $0.id) }
        result.append(contentsOf: tmpMovies.map({TMDb.Media.movie($0)}))
        
        var tmpTVShows = tvShows.compactMap { tvStore.show(withID: $0.id) }
        result.append(contentsOf: tmpTVShows.map({TMDb.Media.tvShow($0)}))
        
        result.append(contentsOf: tmdbMovies.map({TMDb.Media.movie($0)}))
        result.append(contentsOf: tmdbTVShows.map({TMDb.Media.tvShow($0)}))
        result.append(contentsOf: tmdbPerson.map({TMDb.Media.person($0)}))
        
        return result
    }
    
    let title: String
    
    let movies: [Movie]
    let tvShows: [TVShow]
    let tmdbMovies: [TMDb.Movie]
    let tmdbTVShows: [TMDb.TVShow]
    let tmdbPerson: [TMDb.Person]
    
    init(
        title: String = "",
        movies: [Movie] = [],
        tvShows: [TVShow] = [],
        tmdbMovies: [TMDb.Movie] = [],
        tmdbTVShows: [TMDb.TVShow] = [],
        tmdbPerson: [TMDb.Person] = []
    ) {
        self.title = title
        self.movies = movies
        self.tvShows = tvShows
        self.tmdbMovies = tmdbMovies
        self.tmdbTVShows = tmdbTVShows
        self.tmdbPerson = tmdbPerson
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(media, id: \.id) { item in
                        navLink(item: item)
                    }
                }
            }
        }
    }
    
    func navLink(item: TMDb.Media) -> some View {
        switch item {
        case .movie(let movie):
            return AnyView(NavigationLink {
                LazyView {
                    MovieView(id: movie.id)
                }
            } label: {
                ImageView(title: movie.title, url: movieStore.poster(withID: movie.id))
                    .posterStyle(size: .small)
            })

        case .tvShow(let tvShow):
            return AnyView(NavigationLink {
                LazyView {
                    TVShowView(id: tvShow.id)
                }
            } label: {
                ImageView(title: tvShow.name, url: tvStore.poster(withID: tvShow.id))
                    .posterStyle(size: .small)
            })

        case .person(let person):
            return AnyView(NavigationLink {
                Text(person.name)
            } label: {
                ImageView(title: person.name, url: personStore.image(forPerson: person.id))
                    .posterStyle(size: .small)
            })
        }
    }
}
