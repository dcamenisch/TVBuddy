//
//  FeedView.swift
//  tvBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct FeedView: View {
    @EnvironmentObject private var movieStore: MovieStore
    @EnvironmentObject private var tvStore: TVStore

    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<Movie> { !$0.watched })
    private var _movies: [Movie]
    
    @Query(filter: #Predicate<Movie> { $0.watched })
    private var _watchedMovies: [Movie]
    
    @Query
    private var _tvShows: [TVSeries]
    
    @Query
    private var _tvEpisodes: [TVEpisode]
    
    private var movies: [TMDb.Movie] {
        _movies.compactMap { movie in
            movieStore.movie(withID: movie.id)
        }
    }
    
    private var watchedMovies: [TMDb.Movie] {
        _watchedMovies.compactMap { movie in
            movieStore.movie(withID: movie.id)
        }
    }
    
    private var tvShows: [TMDb.TVShow] {
        _tvShows.compactMap { tvShow in
            tvStore.show(withID: tvShow.id)
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                // TODO: TV Show Progress
                Text("TV Episodes (\(_tvEpisodes.count))")
                // TODO: Upcoming Episodes
                MediaList(shows: tvShows, title: "TV Show Watchlist (\(tvShows.count))")
                MediaList(movies: movies, title: "Movie Watchlist (\(movies.count))")
                // TODO: Upcoming Movies
                
                MediaList(movies: watchedMovies, title: "Watched Movies (\(watchedMovies.count))")
            }
            .padding(.horizontal)
        }
        .navigationTitle("Feed")
    }
}
