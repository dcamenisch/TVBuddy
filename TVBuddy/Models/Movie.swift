//
//  Movie.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

@Model
final class Movie {
    @Attribute(.unique)
    let id: Int
    let title: String

    var watched: Bool

    init(id: Int, title: String, watched: Bool) {
        self.id = id
        self.title = title
        self.watched = watched
    }

    convenience init(movie: TMDb.Movie, watched: Bool = false) {
        self.init(id: movie.id, title: movie.title, watched: watched)
    }
}
