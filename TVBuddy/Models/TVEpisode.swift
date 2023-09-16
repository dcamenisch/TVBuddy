//
//  TVEpisode.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData
import TMDb

@Model
final class TVEpisode {
    @Attribute(.unique)
    let id: Int
    
    var tvSeries: TVSeries?
    
    let episodeNumber: Int
    let seasonNumber: Int
        
    var watched: Bool
    
    init(tvEpisode: TMDb.TVShowEpisode, watched: Bool = false) {
        self.id = tvEpisode.id
                
        self.episodeNumber = tvEpisode.episodeNumber
        self.seasonNumber = tvEpisode.seasonNumber
        
        self.watched = watched
    }
}
