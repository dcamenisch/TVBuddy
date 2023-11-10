//
//  TVShow.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

@Model
final class TVShow {
    @Attribute(.unique)
    let id: Int
    let name: String

    @Relationship(deleteRule: .cascade, inverse: \TVEpisode.tvShow)
    var episodes: [TVEpisode] = []

    var startedWatching: Bool
    var finishedWatching: Bool

    init(id: Int, name: String, startedWatching: Bool, finishedWatching: Bool) {
        self.id = id
        self.name = name
        self.startedWatching = startedWatching
        self.finishedWatching = finishedWatching
    }

    convenience init(
        tvShow: TMDb.TVShow, startedWatching: Bool = false, finishedWatching: Bool = false
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
        startedWatching = episodes.contains { $0.watched }
        finishedWatching = episodes.allSatisfy { $0.watched }
    }
}
