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
        private(set) var id: Int

        var name: String
        var firstAirDate: Date?
        var lastAirDate: Date?

        @Relationship(deleteRule: .cascade, inverse: \TVBuddyMediaSchemaV1.TVBuddyTVEpisode.tvShow)
        var episodes: [TVBuddyMediaSchemaV1.TVBuddyTVEpisode] = []

        var isFavorite: Bool
        var isArchived: Bool

        var startedWatching: Bool {
            if episodes.isEmpty { return false }
            return episodes.contains(where: { $0.watched })
        }

        var finishedWatching: Bool {
            episodes.allSatisfy({ $0.watched })
        }

        init(
            id: Int,
            name: String,
            firstAirDate: Date?,
            lastAirDate: Date?,
            isFavorite: Bool = false,
            isArchived: Bool = false
        ) {
            self.id = id
            self.name = name
            self.firstAirDate = firstAirDate
            self.lastAirDate = lastAirDate
            self.isFavorite = isFavorite
            self.isArchived = isArchived
        }

        convenience init(
            tvShow: TVSeries,
            isFavorite: Bool = false,
            isArchived: Bool = false
        ) {
            self.init(
                id: tvShow.id,
                name: tvShow.name,
                firstAirDate: tvShow.firstAirDate,
                lastAirDate: tvShow.lastAirDate,
                isFavorite: isFavorite,
                isArchived: isArchived
            )
        }

        func update(tvShow: TVSeries) {
            self.name = tvShow.name
            self.firstAirDate = tvShow.firstAirDate
            self.lastAirDate = tvShow.lastAirDate
        }
    }
}
