//
//  FeedView.swift
//  TVBuddy
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
    private var movies: [Movie]

    @Query(filter: #Predicate<Movie> { $0.watched })
    private var watchedMovies: [Movie]

    @Query(filter: #Predicate<TVShow> { !$0.startedWatching })
    private var tvShows: [TVShow]

    @Query(
        filter: #Predicate<TVEpisode> { !$0.watched && $0.seasonNumber > 0 },
        sort: [SortDescriptor(\TVEpisode.seasonNumber), SortDescriptor(\TVEpisode.episodeNumber)]
    )
    private var tvEpisodes: [TVEpisode]

    //    private var tmdbMovies: [TMDb.Movie] {
    //        movies.compactMap { movieStore.movie(withID: $0.id) }
    //    }
    //
    //    private var watchedTMDBMovies: [TMDb.Movie] {
    //        watchedMovies.compactMap { movieStore.movie(withID: $0.id) }
    //    }
    //
    //    private var tmdbTVShows: [TMDb.TVShow] {
    //        tvShows.compactMap { tvStore.show(withID: $0.id) }
    //    }

    private var firstUnseenTVEpisodes: [TVEpisode] {
        var firstUnseenEpisode: [String: TVEpisode] = [:]

        for tvEpisode in tvEpisodes where firstUnseenEpisode[tvEpisode.tvShow!.name] == nil {
            firstUnseenEpisode[tvEpisode.tvShow!.name] = tvEpisode
        }

        return Array(firstUnseenEpisode.values).sorted { $0.tvShow!.name < $1.tvShow!.name }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {

                VStack(alignment: .leading) {
                    Text("TV Show Progress (\(tvEpisodes.count))")
                        .font(.title2)
                        .bold()
                    ForEach(firstUnseenTVEpisodes) { episode in
                        TVEpisodeRow(
                            tvSeriesID: episode.tvShow!.id,
                            tvSeriesSeasonNumber: episode.seasonNumber,
                            tvSeriesEpisodeNumber: episode.episodeNumber,
                            showOverview: false
                        )
                    }
                }

                MediaList(title: "TV Show Watchlist (\(tvShows.count))", tvShows: tvShows)
                MediaList(title: "Movie Watchlist (\(movies.count))", movies: movies)
                MediaList(title: "Watched Movies (\(watchedMovies.count))", movies: watchedMovies)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Feed")
    }
}
