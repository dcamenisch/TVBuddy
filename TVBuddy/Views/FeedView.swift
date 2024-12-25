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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                TVEpisodeProgressView()
                
                if !tvShows.isEmpty {
                    MediaCollection(title: "TV Show Watchlist", media: tvShows).id(tvShows)
                }
                
                if !unreleasedTVShows.isEmpty {
                    MediaCollection(title: "Upcoming TV Shows", media: unreleasedTVShows).id(unreleasedTVShows)
                }
                
                if !movies.isEmpty {
                    MediaCollection(title: "Movie Watchlist", media: movies).id(movies)
                }
                
                if !unreleasedMovies.isEmpty {
                    MediaCollection(title: "Upcoming Movies", media: unreleasedMovies).id(unreleasedMovies)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .navigationTitle("Feed")
    }
}
