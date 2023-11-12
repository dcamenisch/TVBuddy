//
//  TVSeasonBody.swift
//  TVBuddy
//
//  Created by Danny on 12.11.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct TVSeasonBody: View {
    
    let id: TVSeries.ID
    let tmdbSeason: TVSeason
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let overview = tmdbSeason.overview, !overview.isEmpty {
                Text("Storyline")
                    .font(.title2)
                    .bold()
                Text(overview)
            }
            
            if let episodes = tmdbSeason.episodes {
                Text("Episodes")
                    .font(.title2)
                    .bold()
                ForEach(episodes) { episode in
                    TVEpisodeRow(
                        tvShowID: id,
                        seasonNumber: episode.seasonNumber,
                        episodeNumber: episode.episodeNumber,
                        showOverview: true
                    )
                }
            }
            
        }
    }
}
