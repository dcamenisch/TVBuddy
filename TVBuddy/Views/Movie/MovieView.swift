//
//  MovieView.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct MovieView: View {
    let id: TMDb.Movie.ID

    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var movieStore: MovieStore

    @Query
    private var movies: [Movie]
    private var _movie: Movie? { movies.first }

    private var tmdbMovie: TMDb.Movie? { movieStore.movie(withID: id) }
    private var poster: URL? { movieStore.poster(withID: id) }
    private var backdrop: URL? { movieStore.backdrop(withID: id) }
    private var progress: CGFloat { offset / 350.0 }

    init(id: TMDb.Movie.ID) {
        self.id = id
        _movies = Query(filter: #Predicate<Movie> { $0.id == id })
    }

    var body: some View {
        content
            .toolbarBackground(.black)
            .toolbarBackground(visibility, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(tmdbMovie?.title ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
            }
    }

    @ViewBuilder private var content: some View {
        if let tmdbMovie = tmdbMovie {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                visibility = offset > 290 ? .visible : .hidden
            } content: {
                MovieHeader(movie: tmdbMovie, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)

                VStack {
                    watchButtons
                    details
                }
                .padding(.horizontal)
            }
        } else {
            ProgressView()
        }
    }

    private var watchButtons: some View {
        HStack {
            Button {
                if let movie = _movie {
                    context.delete(movie)
                } else {
                    context.insert(Movie(movie: tmdbMovie!))
                }
            } label: {
                HStack {
                    Image(systemName: _movie == nil ? "plus" : "checkmark")
                    Text("Watchlist")
                }
                .bold()
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                if let movie = _movie {
                    movie.watched.toggle()
                    try? context.save()
                } else {
                    context.insert(Movie(movie: tmdbMovie!, watched: true))
                }
            } label: {
                HStack {
                    Image(
                        systemName: _movie == nil
                            ? "eye" : _movie?.watched ?? false ? "eye.fill" : "eye")
                    Text("Watched")
                }
                .bold()
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Storyline for the Movie
            if tmdbMovie!.overview != nil {
                Text("Storyline")
                    .font(.title2)
                    .bold()
                Text(tmdbMovie!.overview ?? "")
            }

            // Movie Cast
            if let credits = movieStore.credits(forMovie: id), !credits.cast.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Cast")
                        .font(.title2)
                        .bold()
                    PeopleList(credits: credits)
                }
            }

            // Similar Movies
            if let movies = movieStore.recommendations(forMovie: id), !movies.isEmpty {
                MediaList(title: "Similar Movies", tmdbMovies: movies)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
