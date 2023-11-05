//
//  MediaRow.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MediaRow: View {
    let mediaItem: TMDb.Media
    
    @EnvironmentObject private var movieStore: MovieStore
    @EnvironmentObject private var personStore: PersonStore
    @EnvironmentObject private var tvStore: TVStore
    
    var body: some View {
        switch mediaItem {
        case .movie(let movie):
            NavigationLink {
                LazyView {
                    MovieDetailView(id: movie.id)
                }
            } label: {
                movieRow(movie: movie)
            }
        case .tvShow(let tvShow):
            NavigationLink {
                LazyView {
                    TVShowDetailView(id: tvShow.id)
                }
            } label: {
                tvShowRow(tvShow: tvShow)
            }
        case .person(let person):
            NavigationLink {
                
            } label: {
                personRow(person: person)
            }
        }
    }
    
    func movieRow(movie: TMDb.Movie) -> some View {
        HStack(alignment: .center, spacing: 15) {
            ImageView(title: movie.title, url: movieStore.poster(withID: movie.id))
                .posterStyle(size: .small)

            VStack(alignment: .leading, spacing: 5) {
                if let releaseDate = movie.releaseDate {
                    Text(DateFormatter.year.string(from: releaseDate))
                        .foregroundColor(.gray)
                }
                
                Text(movie.title)
                    .font(.system(size: 22, weight: .bold))
                    .lineLimit(2)
            }
        }
    }
    
    func tvShowRow(tvShow: TMDb.TVShow) -> some View {
        HStack(alignment: .center, spacing: 15) {
            ImageView(title: tvShow.name, url: tvStore.poster(withID: tvShow.id))
                .posterStyle(size: .small)

            VStack(alignment: .leading, spacing: 5) {
                if let firstAirDate = tvShow.firstAirDate {
                    Text(DateFormatter.year.string(from: firstAirDate))
                        .foregroundColor(.gray)
                }
                
                Text(tvShow.name)
                    .font(.system(size: 22, weight: .bold))
                    .lineLimit(2)
            }
        }
    }
    
    func personRow(person: TMDb.Person) -> some View {
        HStack(alignment: .center, spacing: 15) {
            ImageView(title: person.name, url: personStore.image(forPerson: person.id))
                .posterStyle(size: .small)

            VStack(alignment: .leading, spacing: 5) {
                Text(person.name)
                    .font(.system(size: 22, weight: .bold))
                    .lineLimit(2)
            }
        }
    }
}
