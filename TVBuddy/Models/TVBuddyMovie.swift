//
//  TVBuddyMovie.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

//typealias TVBuddyMovie = TVBuddyMovieSchemaV2.TVBuddyMovie
//
//enum TVBuddyMovieMigrationPlan: SchemaMigrationPlan {
//    static var stages: [MigrationStage] {
//        [migrateV1toV2]
//    }
//    
//    static var schemas: [any VersionedSchema.Type] {
//        [TVBuddyMovieSchemaV1.self, TVBuddyMovieSchemaV2.self]
//    }
//    
//    static let migrateV1toV2 = MigrationStage.custom(
//        fromVersion: TVBuddyMovieSchemaV1.self,
//        toVersion: TVBuddyMovieSchemaV2.self,
//        willMigrate: nil,
//        didMigrate: { context in
//            let movies = try context.fetch(FetchDescriptor<TVBuddyMovieSchemaV2.TVBuddyMovie>())
//            
//            for movie in movies {
//                movie.isFavorite = false
//            }
//            
//            try context.save()
//        }
//    )
//}
//
//enum TVBuddyMovieSchemaV1: VersionedSchema {
//    static var versionIdentifier = Schema.Version(0, 0, 1)
//    
//    static var models: [any PersistentModel.Type] {
//        [TVBuddyMovie.self]
//    }
//    
//    @Model
//    class TVBuddyMovie {
//        @Attribute(.unique)
//        let id: Int
//
//        let title: String
//
//        var watched: Bool
//
//        init(id: Int, title: String, watched: Bool) {
//            self.id = id
//            self.title = title
//            self.watched = watched
//        }
//
//        convenience init(movie: Movie, watched: Bool = false) {
//            self.init(id: movie.id, title: movie.title, watched: watched)
//        }
//    }
//}
//
//enum TVBuddyMovieSchemaV2: VersionedSchema {
//    static var versionIdentifier = Schema.Version(0, 0, 2)
//    
//    static var models: [any PersistentModel.Type] {
//        [TVBuddyMovie.self]
//    }
//    
//    @Model
//    class TVBuddyMovie {
//        @Attribute(.unique)
//        let id: Int
//
//        let title: String
//
//        var watched: Bool
//        var isFavorite: Bool
//
//        init(id: Int, title: String, watched: Bool, isFavorite: Bool) {
//            self.id = id
//            self.title = title
//            self.watched = watched
//            self.isFavorite = isFavorite
//        }
//
//        convenience init(movie: Movie, watched: Bool = false, isFavorite: Bool = false) {
//            self.init(id: movie.id, title: movie.title, watched: watched, isFavorite: isFavorite)
//        }
//    }
//}

@Model
public final class TVBuddyMovie {
    @Attribute(.unique)
    public let id: Int

    let title: String

    var watched: Bool

    init(id: Int, title: String, watched: Bool) {
        self.id = id
        self.title = title
        self.watched = watched
    }

    convenience init(movie: Movie, watched: Bool = false) {
        self.init(id: movie.id, title: movie.title, watched: watched)
    }
}
