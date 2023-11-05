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
    
    var media = [TMDb.Media]()
    
    let title: String
    
    init(movies: [TMDb.Movie] = [], persons: [TMDb.Person] = [], shows: [TMDb.TVShow] = [], title: String = "") {
        self.title = title
        
        media.append(contentsOf: movies.map({TMDb.Media.movie($0)}))
        media.append(contentsOf: persons.map({TMDb.Media.person($0)}))
        media.append(contentsOf: shows.map({TMDb.Media.tvShow($0)}))
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
                    MovieDetailView(id: movie.id)
                }
            } label: {
                ImageView(title: movie.title, url: movieStore.poster(withID: movie.id))
                    .posterStyle(size: .small)
            })

        case .tvShow(let tvShow):
            return AnyView(NavigationLink {
                LazyView {
                    TVShowDetailView(id: tvShow.id)
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
