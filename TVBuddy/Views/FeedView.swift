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
    
    @Query(filter: #Predicate<TVBuddyMovie> { !$0.watched })
    private var movies: [TVBuddyMovie]

    @Query(filter: #Predicate<TVBuddyMovie> { $0.watched })
    private var watchedMovies: [TVBuddyMovie]

    @Query(filter: #Predicate<TVBuddyTVShow> { !$0.startedWatching })
    private var tvShows: [TVBuddyTVShow]
    
    @Query(filter: #Predicate<TVBuddyTVShow> { $0.finishedWatching })
    private var watchedTVShows: [TVBuddyTVShow]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                TVEpisodeProgressView()
                MediaList(title: "TV Show Watchlist (\(tvShows.count))", tvShows: tvShows)
                MediaList(title: "Watched TV Shows (\(watchedTVShows.count))", tvShows: watchedTVShows)
                MediaList(title: "Movie Watchlist (\(movies.count))", movies: movies)
                MediaList(title: "Watched Movies (\(watchedMovies.count))", movies: watchedMovies)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Feed")
    }
}
