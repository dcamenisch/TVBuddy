//
//  TVSeries.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

@Model
final class TVSeries {
    @Attribute(.unique)
    let id: Int
    let name: String
    
    @Relationship(deleteRule: .cascade, inverse: \TVEpisode.tvSeries)
    var episodes: [TVEpisode] = []
    
    var watching: Bool
    var watched: Bool
    
    init(tvSeries: TMDb.TVShow, watching: Bool = false, watched: Bool = false) {
        self.id = tvSeries.id
        self.name = tvSeries.name
        
        self.watching = watching
        self.watched = watched
    }
}
