//
//  TVBuddyTVEpisode.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

@Model
public final class TVBuddyTVEpisode {
    @Attribute(.unique)
    public let id: Int

    var tvShow: TVBuddyTVShow?

    let episodeNumber: Int
    let seasonNumber: Int

    var watched: Bool

    init(id: Int, episodeNumber: Int, seasonNumber: Int, watched: Bool) {
        self.id = id
        self.episodeNumber = episodeNumber
        self.seasonNumber = seasonNumber
        self.watched = watched
    }

    convenience init(episode: TVEpisode, watched: Bool = false) {
        self.init(
            id: episode.id,
            episodeNumber: episode.episodeNumber,
            seasonNumber: episode.seasonNumber,
            watched: watched
        )
    }

    func toggleWatched() {
        watched.toggle()
        tvShow?.checkWatching()
    }
}
