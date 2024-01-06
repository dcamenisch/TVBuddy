//
//  TVBuddyTVShow.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

typealias TVBuddyTVShow = TVBuddyMediaSchemaV1.TVBuddyTVShow

extension TVBuddyMediaSchemaV1 {
    @Model
    final class TVBuddyTVShow: Identifiable, Equatable, Hashable {
        @Attribute(.unique)
        public let id: Int

        var name: String
        var firstAirDate: Date?
        var lastAirDate: Date?

        @Relationship(deleteRule: .cascade, inverse: \TVBuddyTVEpisode.tvShow)
        var episodes: [TVBuddyTVEpisode] = []

        var startedWatching: Bool
        var finishedWatching: Bool
        var isFavorite: Bool
        var isArchived: Bool

        init(id: Int, name: String, firstAirDate: Date?, lastAirDate: Date?, startedWatching: Bool, finishedWatching: Bool, isFavorite: Bool = false, isArchived: Bool = false) {
            self.id = id
            self.name = name
            self.firstAirDate = firstAirDate
            self.lastAirDate = lastAirDate
            self.startedWatching = startedWatching
            self.finishedWatching = finishedWatching
            self.isFavorite = isFavorite
            self.isArchived = isArchived
        }

        convenience init(
            tvShow: TVSeries, startedWatching: Bool = false, finishedWatching: Bool = false, isFavorite: Bool = false, isArchived: Bool = false
        ) {
            self.init(
                id: tvShow.id,
                name: tvShow.name,
                firstAirDate: tvShow.firstAirDate,
                lastAirDate: tvShow.lastAirDate,
                startedWatching: startedWatching,
                finishedWatching: finishedWatching,
                isFavorite: isFavorite,
                isArchived: isArchived
            )
        }
        
        func update(tvShow: TVSeries) {
            self.name = tvShow.name
            self.firstAirDate = tvShow.firstAirDate
            self.lastAirDate = tvShow.lastAirDate
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
}
