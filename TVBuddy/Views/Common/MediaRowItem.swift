//
//  MediaRowItem.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MediaRowItem: View {
    let mediaItem: Media

    var body: some View {
        switch mediaItem {
        case let .movie(movie):
            MovieRow(id: movie.id)
        case let .tvSeries(tvShow):
            TVShowRow(id: tvShow.id)
        case let .person(person):
            PersonRow(person: person)
        }
    }
}
