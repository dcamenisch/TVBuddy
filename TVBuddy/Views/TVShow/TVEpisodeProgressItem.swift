//
//  TVEpisodeProgressItem.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI

struct TVEpisodeProgressItem: View {
    let tvShow: TVBuddyTVShow

    @Query
    private var tvEpisodes: [TVBuddyTVEpisode]
    private var tvEpisode: TVBuddyTVEpisode? { tvEpisodes.first }

    init(tvShow: TVBuddyTVShow) {
        self.tvShow = tvShow

        let id = tvShow.id
        let now = Date.now
        let future = Date.distantFuture
        
        _tvEpisodes = Query(
            filter: #Predicate<TVBuddyTVEpisode> { $0.tvShow?.id == id && $0.seasonNumber > 0 && !$0.watched && $0.airDate ?? future <= now},
            sort: [SortDescriptor(\TVBuddyTVEpisode.seasonNumber), SortDescriptor(\TVBuddyTVEpisode.episodeNumber)]
        )
    }

    var body: some View {
        Group {
            if let tvEpisode = tvEpisode {
                TVEpisodeRow(
                    tvShowID: tvShow.id,
                    seasonNumber: tvEpisode.seasonNumber,
                    episodeNumber: tvEpisode.episodeNumber,
                    showOverview: false,
                    clickable: true
                )
            }
        }
    }
}
