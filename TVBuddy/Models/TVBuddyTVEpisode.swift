//
//  TVBuddyTVEpisode.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

typealias TVBuddyTVEpisode = TVBuddyMediaSchemaV1.TVBuddyTVEpisode

extension TVBuddyMediaSchemaV1 {
    @Model
    public final class TVBuddyTVEpisode {
        @Attribute(.unique)
        public let id: Int

        var tvShow: TVBuddyTVShow?

        let episodeNumber: Int
        let seasonNumber: Int
        
        let airDate: Date?

        var watched: Bool

        init(id: Int, episodeNumber: Int, seasonNumber: Int, airDate: Date?, watched: Bool) {
            self.id = id
            self.episodeNumber = episodeNumber
            self.seasonNumber = seasonNumber
            self.airDate = airDate
            self.watched = watched
        }

        convenience init(episode: TVEpisode, watched: Bool = false) {
            self.init(
                id: episode.id,
                episodeNumber: episode.episodeNumber,
                seasonNumber: episode.seasonNumber,
                airDate: episode.airDate,
                watched: watched
            )
        }

        func toggleWatched() {
            watched.toggle()
            tvShow?.checkWatching()
        }
    }
}
