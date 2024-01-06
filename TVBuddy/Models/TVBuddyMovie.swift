//
//  TVBuddyMovie.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

typealias TVBuddyMovie = TVBuddyMediaSchemaV1.TVBuddyMovie

extension TVBuddyMediaSchemaV1 {
    @Model
    final class TVBuddyMovie: Identifiable, Equatable, Hashable {
        @Attribute(.unique)
        let id: Int

        var title: String
        var releaseDate: Date?

        var watched: Bool
        var isFavorite: Bool

        init(id: Int, title: String, releaseDate: Date?, watched: Bool, isFavorite: Bool) {
            self.id = id
            self.title = title
            self.releaseDate = releaseDate
            self.watched = watched
            self.isFavorite = isFavorite
        }

        convenience init(movie: Movie, watched: Bool = false, isFavorite: Bool = false) {
            self.init(
                id: movie.id,
                title: movie.title,
                releaseDate: movie.releaseDate,
                watched: watched,
                isFavorite: isFavorite
            )
        }
        
        func update(movie: Movie) {
            self.title = movie.title
            self.releaseDate = movie.releaseDate
        }
    }
}
