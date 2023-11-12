//
//  Media.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import Foundation
import TMDb

public enum Media: Identifiable, Equatable, Hashable {

    public var id: Int {
        switch self {
        case .movie(let movie):
            return movie.id
            
        case .tvShow(let tvShow):
            return tvShow.id
            
        case .tmdbMovie(let tmdbMovie):
            return tmdbMovie.id

        case .tmdbTVShow(let tmdbTVShow):
            return tmdbTVShow.id

        case .tmdbPerson(let tmdbPerson):
            return tmdbPerson.id
        }
    }
    
    public var name: String {
        switch self {
        case .movie(let movie):
            return movie.title
            
        case .tvShow(let tvShow):
            return tvShow.name
            
        case .tmdbMovie(let tmdbMovie):
            return tmdbMovie.title

        case .tmdbTVShow(let tmdbTVShow):
            return tmdbTVShow.name

        case .tmdbPerson(let tmdbPerson):
            return tmdbPerson.name
        }
    }

    case movie(Movie)
    case tvShow(TVShow)
    
    case tmdbMovie(TMDb.Movie)
    case tmdbTVShow(TMDb.TVShow)
    case tmdbPerson(TMDb.Person)

}
