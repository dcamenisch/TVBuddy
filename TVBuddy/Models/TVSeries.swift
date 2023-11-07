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
    
    var startedWatching: Bool
    var finishedWatching: Bool
    
    init(tvSeries: TMDb.TVShow, startedWatching: Bool = false, finishedWatching: Bool = false) {
        self.id   = tvSeries.id
        self.name = tvSeries.name
        
        self.startedWatching  = startedWatching
        self.finishedWatching = finishedWatching
    }
}
