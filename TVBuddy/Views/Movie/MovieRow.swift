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
    @State private var viewModel: ViewModel
    
    @Environment(\.modelContext) private var context
        
    @Query
    private var tvbMovies: [TVBuddyMovie]
    private var tvbMovie: TVBuddyMovie? { tvbMovies.first }
        
    init(id: Movie.ID) {
        _tvbMovies = Query(filter: #Predicate<TVBuddyMovie> { $0.id == id })
        
        let viewModel = ViewModel(forMovie: id)
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        if let movie = viewModel.movie {
            NavigationLink {
                movie.detailView
            } label: {
                HStack {
                    ImageView(
                        url: viewModel.posterURL,
                        placeholder: movie.title
                    )
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
        } else {
            ProgressView()
        }
    }
    
    private func toggleMovieInWatchlist() {
        if let tvbMovie = tvbMovie {
            context.delete(tvbMovie)
            try? context.save()
        } else if let movie = viewModel.movie {
            context.insert(TVBuddyMovie(movie: movie, watched: false))
            try? context.save()
        }
    }
    
    private func buttonImage() -> String {
        if let tvbMovie = tvbMovie {
            return tvbMovie.watched ? "eye.circle" : "checkmark.circle"
        } else {
            return "plus.circle"
        }
    }
}

extension MovieRow {
    @MainActor @Observable
    class ViewModel {
        let id: Movie.ID
        
        private(set) var movie: Movie?
        private(set) var posterURL: URL?
        
        init(forMovie id: Movie.ID) {
            self.id = id
            fetchData()
        }
        
        func fetchData() {
            Task {
                movie = await MovieStore.shared.movie(withID: id)
                posterURL = await movie?.getPosterURL()
            }
        }
    }
}
