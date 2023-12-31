//
//  TVEpisodeProgressView.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI

struct TVEpisodeProgressView: View {
    @Query(filter: #Predicate<TVBuddyTVShow> { $0.startedWatching && !$0.finishedWatching && !$0.isArchived })
    private var tvShows: [TVBuddyTVShow]

    var body: some View {
        VStack(alignment: .leading) {
            Text("TV Show Progress")
                .font(.title2)
                .bold()
            ForEach(tvShows) { tvShow in
                TVEpisodeProgressItem(tvShow: tvShow)
            }
        }
    }
}
