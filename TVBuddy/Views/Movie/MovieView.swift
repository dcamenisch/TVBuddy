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
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var movieStore: MovieStore

    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden

    @State var tmdbMovie: Movie?
    @State var poster: URL?
    @State var backdrop: URL?

    @Query
    private var movies: [TVBuddyMovie]
    private var _movie: TVBuddyMovie? { movies.first }

    let id: Movie.ID

    private var progress: CGFloat { backdrop != nil ? offset / 350.0 : offset / 100.0}

    init(id: Movie.ID) {
        self.id = id
        _movies = Query(filter: #Predicate<TVBuddyMovie> { $0.id == id })
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

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let movie = _movie {
                            movie.isFavorite.toggle()
                        } else if let tmdbMovie = tmdbMovie {
                            context.insert(TVBuddyMovie(movie: tmdbMovie, watched: true, isFavorite: true))
                        }
                    } label: {
                        Image(systemName: _movie?.isFavorite ?? false ? "heart.fill" : "heart")
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                    }
                }
            }
            .task {
                tmdbMovie = await movieStore.movie(withID: id)
                poster = await movieStore.poster(withID: id)
                backdrop = await movieStore.backdrop(withID: id)
            }
    }

    @ViewBuilder private var content: some View {
        if let tmdbMovie = tmdbMovie {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                if backdrop == nil {
                    visibility = offset > 0 ? .visible : .hidden
                } else {
                    visibility = offset > 290 ? .visible : .hidden
                }
            } content: {
                MovieHeader(movie: tmdbMovie, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                MovieBody(tmdbMovie: tmdbMovie, tvBuddyMovie: _movie)
                    .padding(.horizontal)
            }
        } else {
            ProgressView()
        }
    }
}
