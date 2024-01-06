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
    
    @State var poster: URL?
    
    @Query
    private var movies: [TVBuddyMovie]
    
    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        _movies = Query(filter: #Predicate<TVBuddyMovie> { $0.id == movie.id })
    }
    
    var body: some View {
        NavigationLink {
            movie.detailView
        } label: {
            HStack {
                ImageView(url: poster, placeholder: movie.title)
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
                
                Button(action: toggleMovieInWatchlist) {
                    Image(systemName: buttonImage())
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
        .task(id: movie) {
            poster = await MovieStore.shared.poster(withID: movie.id)
        }
    }
    
    private func toggleMovieInWatchlist() {
        if let movie = movies.first {
            context.delete(movie)
            try? context.save()
        } else {
            context.insert(TVBuddyMovie(movie: movie, watched: false))
            try? context.save()
        }
    }
    
    private func buttonImage() -> String {
        if let movie = movies.first {
            return movie.watched ? "eye.circle" : "checkmark.circle"
        } else {
            return "plus.circle"
        }
    }
}
