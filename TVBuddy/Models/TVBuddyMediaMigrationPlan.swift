//
//  TVBuddyMediaMigrationPlan.swift
//  TVBuddy
//
//  Created by Danny on 24.11.2023.
//

import Foundation
import SwiftData

enum TVBuddyMediaMigrationPlan: SchemaMigrationPlan {
    static var stages: [MigrationStage] {
        []
    }
    
    static var schemas: [any VersionedSchema.Type] {
        [TVBuddyMediaSchemaV1.self]
    }
    
//    static let migrateV1toV2 = MigrationStage.custom(
//        fromVersion: TVBuddyMediaSchemaV1.self,
//        toVersion: TVBuddyMediaSchemaV2.self,
//        willMigrate: nil,
//        didMigrate: { context in
//            let movies = try context.fetch(FetchDescriptor<TVBuddyMediaSchemaV2.TVBuddyMovie>())
//
//            for movie in movies {
//                movie.isFavorite = false
//            }
//
//            try context.save()
//        }
//    )
}
