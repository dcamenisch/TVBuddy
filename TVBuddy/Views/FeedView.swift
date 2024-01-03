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
    @Query
    private var movies: [TVBuddyMovie]

    @Query
    private var unreleasedMovies: [TVBuddyMovie]

    @Query
    private var tvShows: [TVBuddyTVShow]

    @Query
    private var unreleasedTVShows: [TVBuddyTVShow]

    init() {
        let now = Date.now
        let future = Date.distantFuture

        _movies = Query(filter: #Predicate<TVBuddyMovie> { !$0.watched && $0.releaseDate ?? future <= now })
        _unreleasedMovies = Query(filter: #Predicate<TVBuddyMovie> { !$0.watched && $0.releaseDate ?? future > now })

        _tvShows = Query(filter: #Predicate<TVBuddyTVShow> { !$0.startedWatching && $0.firstAirDate ?? future <= now })
        _unreleasedTVShows = Query(filter: #Predicate<TVBuddyTVShow> { !$0.startedWatching && $0.firstAirDate ?? future > now })
    }

    var body: some View {
        let _ = Self._printChanges()
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                // Structure:
                // - Progress
                // - Upcoming Episodes
                // - Show Watchlist
                // - Movie Watchlist
                
                TVEpisodeProgressView()
                MediaCollection(title: "TV Show Watchlist (\(tvShows.count))", tvShows: tvShows)
                MediaCollection(title: "Upcoming TV Shows (\(unreleasedTVShows.count))", tvShows: unreleasedTVShows)
                MediaCollection(title: "Movie Watchlist (\(movies.count))", movies: movies)
                MediaCollection(title: "Upcoming Movies (\(unreleasedMovies.count))", movies: unreleasedMovies)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Feed")
    }
}
