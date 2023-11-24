//
//  TVBuddyMediaItem.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import Foundation
import TMDb

enum TVBuddyMediaItem: Identifiable, Equatable, Hashable {
    public var id: Int {
        switch self {
        case let .movie(movie):
            return movie.id

        case let .tvShow(tvShow):
            return tvShow.id

        case let .tmdbMovie(tmdbMovie):
            return tmdbMovie.id

        case let .tmdbTVShow(tmdbTVShow):
            return tmdbTVShow.id

        case let .tmdbPerson(tmdbPerson):
            return tmdbPerson.id
        }
    }

    public var name: String {
        switch self {
        case let .movie(movie):
            return movie.title

        case let .tvShow(tvShow):
            return tvShow.name

        case let .tmdbMovie(tmdbMovie):
            return tmdbMovie.title

        case let .tmdbTVShow(tmdbTVShow):
            return tmdbTVShow.name

        case let .tmdbPerson(tmdbPerson):
            return tmdbPerson.name
        }
    }

    case movie(TVBuddyMovie)
    case tvShow(TVBuddyTVShow)

    case tmdbMovie(Movie)
    case tmdbTVShow(TVSeries)
    case tmdbPerson(Person)
}
