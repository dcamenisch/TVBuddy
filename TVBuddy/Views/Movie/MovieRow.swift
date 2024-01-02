//
//  MovieRow.swift
//  TVBuddy
//
//  Created by Danny on 02.01.2024.
//

import SwiftData
import SwiftUI
import TMDb

struct MovieRow: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var movieStore: MovieStore
    
    @State var poster: URL?
    
    @Query
    private var movies: [TVBuddyMovie]
    private var _movie: TVBuddyMovie? { movies.first }
    
    private var isOnWatchlist: Bool {
        _movie != nil
    }
    
    private var markedAsSeen: Bool {
        guard let movie = _movie else { return false }
        return movie.watched
    }
    
    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        _movies = Query(filter: #Predicate<TVBuddyMovie> { $0.id == movie.id })
    }
    
    var body: some View {
        NavigationLink {
            MovieView(id: movie.id)
        } label: {
            HStack {
                ImageView(title: movie.title, url: poster)
                    .posterStyle(size: .tiny)
                
                VStack(alignment: .leading, spacing: 5) {
                    if let releaseDate = movie.releaseDate {
                        Text(DateFormatter.year.string(from: releaseDate))
                            .foregroundColor(.gray)
                    }
                    
                    Text(movie.title)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button {
                    if let movie = _movie {
                        context.delete(movie)
                    } else {
                        context.insert(TVBuddyMovie(movie: movie, watched: false))
                    }
                } label: {
                    Image(systemName: isOnWatchlist ? markedAsSeen ? "eye.circle" : "checkmark.circle" : "plus.circle")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
        .task(id: movie) {
            poster = await movieStore.poster(withID: movie.id)
        }
    }
}
