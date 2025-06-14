//
//  TVSeasonProgressBar.swift
//  TVBuddy
//
//  Created by Danny on 07.01.2024.
//

import SwiftData
import SwiftUI
import TMDb

struct SeasonProgressView: View {
    @Environment(\.modelContext) private var context

    let tvShow: TVSeries
    let seasonNumber: Int

    private var progress: Double {
        if tvbEpisodes.count == 0 { return 0.0 }
        return Double(tvbEpisodes.count(where: { $0.watched })) / Double(tvbEpisodes.count)
    }

    @Query
    private var tvbEpisodes: [TVBuddyTVEpisode]

    init(tvShow: TVSeries, seasonNumber: Int) {
        self.tvShow = tvShow
        self.seasonNumber = seasonNumber
        _tvbEpisodes = Query(
            filter: #Predicate<TVBuddyTVEpisode> {
                $0.tvShow?.id ?? 0 == tvShow.id && $0.seasonNumber == seasonNumber
            }
        )
    }

    var body: some View {
        CircularProgressBar(progress: progress, strokeWidth: 5) {
            Text(seasonNumber == 0 ? "S" : String(seasonNumber))
                .foregroundStyle(Color.foreground2)
                .font(.title2)
                .bold()
        }
    }
}
