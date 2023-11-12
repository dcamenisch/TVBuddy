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
    
    @State var credits: TMDb.ShowCredits?
    @State var recommendations: [TMDb.Movie]?
    
    @Query
    private var movies: [Movie]
    private var _movie: Movie? { movies.first }
    
    private var tmdbMovie: TMDb.Movie
    
    init(tmdbMovie: TMDb.Movie, id: TMDb.Movie.ID) {
        self.tmdbMovie = tmdbMovie
        _movies = Query(filter: #Predicate<Movie> { $0.id == id })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            watchButtons
            overview
            cast
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
                    context.insert(Movie(movie: tmdbMovie, watched: false))
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
                    context.insert(Movie(movie: tmdbMovie, watched: true))
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
    
    private var cast: some View {
        Group {
            if let credits = credits, !credits.cast.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Cast")
                        .font(.title2)
                        .bold()
                    PeopleList(credits: credits)
                }
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
