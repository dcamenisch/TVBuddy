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

    private var tmdbMovie: Movie
    private var tvBuddyMovie: TVBuddyMovie?

    init(tmdbMovie: Movie, tvBuddyMovie: TVBuddyMovie?) {
        self.tmdbMovie = tmdbMovie
        self.tvBuddyMovie = tvBuddyMovie
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            watchButtons
            overview
            genres

            if let credits = credits, !credits.cast.isEmpty {
                PeopleList(credits: credits)
            }

            similarMovies
        }
        .task(id: tmdbMovie) {
            credits = await movieStore.credits(forMovie: tmdbMovie.id)
            recommendations = await movieStore.recommendations(forMovie: tmdbMovie.id)
        }
    }

    private var watchButtons: some View {
        HStack {
            Button {
                if let movie = tvBuddyMovie {
                    context.delete(movie)
                } else {
                    context.insert(TVBuddyMovie(movie: tmdbMovie, watched: false))
                }
            } label: {
                Label("Watchlist", systemImage: tvBuddyMovie == nil ? "plus" : "checkmark")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }
            
            Button {
                if let movie = tvBuddyMovie {
                    movie.watched.toggle()
                } else {
                    context.insert(TVBuddyMovie(movie: tmdbMovie, watched: true))
                }
            } label: {
                Label("Watched", systemImage: tvBuddyMovie?.watched ?? false ? "eye.fill" : "eye")
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

    private var genres: some View {
        Group {
            if let genres = tmdbMovie.genres {
                WrappingHStack(models: genres) { genre in
                    Text(genre.name)
                        .font(.headline)
                        .padding(.horizontal, 10.0)
                        .padding(.vertical, 8.0)
                        .background {
                            RoundedRectangle(cornerRadius: 15.0, style: .circular)
                                .foregroundColor(Color(UIColor.systemGray6))
                        }
                }
            }
        }
    }

    private var similarMovies: some View {
        Group {
            if let movies = recommendations, !movies.isEmpty {
                MediaCollection(title: "Recommendations", tmdbMovies: movies)
            }
        }
    }
}
