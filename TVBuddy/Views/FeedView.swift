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
    
    @Query(
        filter: #Predicate<TVEpisode> { !$0.watched && $0.seasonNumber > 0},
        sort: [SortDescriptor(\TVEpisode.seasonNumber), SortDescriptor(\TVEpisode.episodeNumber)]
    )
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
    
    private var tvEpisodes: [TVEpisode] {
        var firstEpisode: [String: TVEpisode] = [:]
        
        for tvEpisode in _tvEpisodes where firstEpisode[tvEpisode.tvSeries!.name] == nil {
            firstEpisode[tvEpisode.tvSeries!.name] = tvEpisode
        }

        return Array(firstEpisode.values).sorted { ep1, ep2 in
            ep1.tvSeries!.name < ep2.tvSeries!.name
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                
                VStack(alignment: .leading) {
                    Text("TV Series Progress (\(_tvEpisodes.count))")
                        .font(.title2)
                        .bold()
                    ForEach(tvEpisodes) { tvEpisode in
                        TVEpisodeRow(
                            tvSeriesID: tvEpisode.tvSeries!.id,
                            tvSeriesSeasonNumber: tvEpisode.seasonNumber,
                            tvSeriesEpisodeNumber: tvEpisode.episodeNumber,
                            showOverview: false
                        )
                    }
                }
                
                MediaList(shows: tvShows, title: "TV Series Watchlist (\(tvShows.count))")
                MediaList(movies: movies, title: "Movie Watchlist (\(movies.count))")
                MediaList(movies: watchedMovies, title: "Watched Movies (\(watchedMovies.count))")
            }
            .padding(.horizontal)
        }
        .navigationTitle("Feed")
    }
}
