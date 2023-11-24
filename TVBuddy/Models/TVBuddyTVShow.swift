//
//  TVBuddyTVShow.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

@Model
public final class TVBuddyTVShow {
    @Attribute(.unique)
    public let id: Int

    let name: String

    @Relationship(deleteRule: .cascade, inverse: \TVBuddyTVEpisode.tvShow)
    var episodes: [TVBuddyTVEpisode] = []

    var startedWatching: Bool
    var finishedWatching: Bool

    init(id: Int, name: String, startedWatching: Bool, finishedWatching: Bool) {
        self.id = id
        self.name = name
        self.startedWatching = startedWatching
        self.finishedWatching = finishedWatching
    }

    convenience init(
        tvShow: TVSeries, startedWatching: Bool = false, finishedWatching: Bool = false
    ) {
        self.init(
            id: tvShow.id,
            name: tvShow.name,
            startedWatching: startedWatching,
            finishedWatching: finishedWatching
        )
    }

    func toggleWatched() {
        episodes.forEach { $0.watched = !finishedWatching }
        checkWatching()
    }

    func checkWatching() {
        startedWatching = episodes.contains { $0.watched && $0.seasonNumber != 0 }
        finishedWatching = episodes.allSatisfy { $0.watched || $0.seasonNumber == 0 }
    }
}
