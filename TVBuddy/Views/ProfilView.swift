//
//  ProfilView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftData
import SwiftUI
import TMDb


struct ProfilView: View {
    @Query(filter: #Predicate<TVBuddyMovie> { $0.watched })
    private var watchedMovies: [TVBuddyMovie]

    @Query(filter: #Predicate<TVBuddyTVShow> { $0.finishedWatching })
    private var watchedTVShows: [TVBuddyTVShow]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                MediaCollection(title: "Watched TV Shows (\(watchedTVShows.count))", tvShows: watchedTVShows)
                MediaCollection(title: "Watched Movies (\(watchedMovies.count))", movies: watchedMovies)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Profil")
    }
}
