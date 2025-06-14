//
//  TVBuddyMediaSchema.swift
//  TVBuddy
//
//  Created by Danny on 24.11.2023.
//

import Foundation
import SwiftData

typealias TVBuddyMediaSchema = TVBuddyMediaSchemaV1

enum TVBuddyMediaSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(0, 1, 0)

    static var models: [any PersistentModel.Type] {
        [TVBuddyMediaSchemaV1.TVBuddyMovie.self, TVBuddyMediaSchemaV1.TVBuddyTVShow.self, TVBuddyMediaSchemaV1.TVBuddyTVEpisode.self]
    }
}
