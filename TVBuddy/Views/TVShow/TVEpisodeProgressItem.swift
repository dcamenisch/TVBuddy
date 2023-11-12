//
//  TVEpisodeProgressItem.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI

struct TVEpisodeProgressItem: View {
    let tvShow: TVShow
        
    @Query
    private var tvEpisodes: [TVEpisode]
    private var tvEpisode: TVEpisode? { tvEpisodes.first }
    
    init(tvShow: TVShow) {
        self.tvShow = tvShow
        
        let id = tvShow.id
        _tvEpisodes = Query(
            filter: #Predicate<TVEpisode> { $0.tvShow?.id == id && $0.seasonNumber > 0 && !$0.watched},
            sort: [SortDescriptor(\TVEpisode.seasonNumber), SortDescriptor(\TVEpisode.episodeNumber)]
        )
    }
    
    var body: some View {
        Group {
            if let tvEpisode = tvEpisode {
                TVEpisodeRow(
                    tvShowID: tvShow.id,
                    seasonNumber: tvEpisode.seasonNumber,
                    episodeNumber: tvEpisode.episodeNumber,
                    showOverview: false
                )
            }
        }
    }
}
