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

    @State private var offset: CGFloat = 0.0
    @State private var visibility: Visibility = .hidden

    @State private var movie: Movie?
    @State private var poster: URL?
    @State private var backdrop: URL?

    @Query
    private var tvbMovies: [TVBuddyMovie]
    private var tvbMovie: TVBuddyMovie? { tvbMovies.first }

    private var progress: CGFloat { backdrop != nil ? offset / 350.0 : offset / 100.0 }

    private let id: Movie.ID

    init(id: Movie.ID) {
        self.id = id
        _tvbMovies = Query(filter: #Predicate<TVBuddyMovie> { $0.id == id })
    }

    var body: some View {
        content
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
                    Text(movie?.title ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let container = context.container
                        let movieActor = MovieActor(modelContainer: container)
                        if let movieID = self.movie?.id {  // Ensure movie ID is available
                            Task {
                                await movieActor.toggleFavorite(movieID: movieID)
                            }
                        }
                    } label: {
                        Image(systemName: tvbMovie?.isFavorite ?? false ? "heart.fill" : "heart")
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                    }
                }
            }
            .task {
                movie = await MovieStore.shared.movie(withID: id)
                poster = await MovieStore.shared.posters(withID: id).first
                backdrop = await MovieStore.shared.backdrops(withID: id).first
            }
    }

    @ViewBuilder
    private var content: some View {
        if let movie = movie {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                if backdrop == nil {
                    visibility = offset > 0 ? .visible : .hidden
                } else {
                    visibility = offset > 290 ? .visible : .hidden
                }
            } content: {
                MovieHeader(movie: movie, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                MovieBody(movie: movie, tvbMovie: tvbMovie)
                    .padding(.horizontal)
                Spacer()
            }
        } else {
            ProgressView()
        }
    }
}
