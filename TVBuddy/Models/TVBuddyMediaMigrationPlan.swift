//
//  TVBuddyMediaMigrationPlan.swift
//  TVBuddy
//
//  Created by Danny on 24.11.2023.
//

import Foundation
import SwiftData

enum TVBuddyMediaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            TVBuddyMediaSchemaV1.self,
        ]
    }

    static var stages: [MigrationStage] {
        []
    }

//    static let migrateV1toV2 = MigrationStage.lightweight(
//        fromVersion: TVBuddyMediaSchemaV1.self,
//        toVersion: TVBuddyMediaSchemaV2.self,
//    )
}
