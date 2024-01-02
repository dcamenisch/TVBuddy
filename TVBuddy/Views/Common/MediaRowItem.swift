//
//  MediaRowItem.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MediaRowItem: View {
    let mediaItem: Media

    var body: some View {
        switch mediaItem {
        case let .movie(movie):
            ZStack(alignment: .leading) {
                NavigationLink {
                    MovieView(id: movie.id)
                } label: {
                    EmptyView()
                }.opacity(0)
                
                MovieRowItem(movie: movie)
            }
        case let .tvSeries(tvShow):
            ZStack(alignment: .leading) {
                NavigationLink {
                    TVShowView(id: tvShow.id)
                } label: {
                    EmptyView()
                }.opacity(0)
                
                TVShowRowItem(tvShow: tvShow)
            }
        case let .person(person):
            PersonRowItem(person: person)
        }
    }
}

struct MovieRowItem: View {
    let movie: Movie

    @EnvironmentObject private var movieStore: MovieStore
    @State var poster: URL?

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            ImageView(title: movie.title, url: poster)
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
        .task {
            poster = await movieStore.poster(withID: movie.id)
        }
    }
}

struct TVShowRowItem: View {
    let tvShow: TVSeries

    @EnvironmentObject private var tvStore: TVStore
    @State var poster: URL?

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            ImageView(title: tvShow.name, url: poster)
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
        .task {
            poster = await tvStore.poster(withID: tvShow.id)
        }
    }
}

struct PersonRowItem: View {
    let person: Person

    @EnvironmentObject private var personStore: PersonStore
    @State var image: URL?

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            ImageView(title: person.name, url: image)
                .posterStyle(size: .small)

            VStack(alignment: .leading, spacing: 5) {
                Text(person.name)
                    .font(.system(size: 22, weight: .bold))
                    .lineLimit(2)
            }
        }
        .task {
            image = await personStore.image(forPerson: person.id)
        }
    }
}
