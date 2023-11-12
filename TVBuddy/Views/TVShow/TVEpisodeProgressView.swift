//
//  TVEpisodeProgressView.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI

struct TVEpisodeProgressView: View {
    
    @Query(filter: #Predicate<TVShow> {$0.startedWatching && !$0.finishedWatching})
    private var tvShows: [TVShow]

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
