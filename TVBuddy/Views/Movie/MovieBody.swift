//
//  MovieBody.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct MovieBody: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var movieStore: MovieStore

    @State var credits: ShowCredits?
    @State var recommendations: [Movie]?

    @Query
    private var movies: [TVBuddyMovie]
    private var _movie: TVBuddyMovie? { movies.first }

    private var tmdbMovie: Movie

    init(tmdbMovie: Movie, id: Movie.ID) {
        self.tmdbMovie = tmdbMovie
        _movies = Query(filter: #Predicate<TVBuddyMovie> { $0.id == id })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            watchButtons
            overview

            if let credits = credits, !credits.cast.isEmpty {
                PeopleList(credits: credits)
            }

            similarMovies
        }
        .task {
            credits = await movieStore.credits(forMovie: tmdbMovie.id)
            recommendations = await movieStore.recommendations(forMovie: tmdbMovie.id)
        }
    }

    private var watchButtons: some View {
        HStack {
            Button {
                if let movie = _movie {
                    context.delete(movie)
                } else {
                    context.insert(TVBuddyMovie(movie: tmdbMovie, watched: false))
                }
            } label: {
                HStack {
                    Image(systemName: _movie == nil ? "plus" : "checkmark")
                    Text("Watchlist")
                }
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }

            Button {
                if let movie = _movie {
                    movie.watched.toggle()
                } else {
                    context.insert(TVBuddyMovie(movie: tmdbMovie, watched: true))
                }
            } label: {
                HStack {
                    Image(
                        systemName: _movie == nil
                            ? "eye" : _movie?.watched ?? false ? "eye.fill" : "eye")
                    Text("Watched")
                }
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }
        }
        .bold()
        .buttonStyle(.bordered)
    }

    private var overview: some View {
        Group {
            if tmdbMovie.overview != nil {
                Text("Storyline")
                    .font(.title2)
                    .bold()
                Text(tmdbMovie.overview ?? "")
            }
        }
    }

    private var similarMovies: some View {
        Group {
            if let movies = recommendations, !movies.isEmpty {
                MediaList(title: "Similar Movies", tmdbMovies: movies)
            }
        }
    }
}
