//
//  Movie.swift
//  TVBuddy
//
//  Created by Danny on 24.09.2023.
//

import Foundation
import SwiftData

@Model
final class Movie {
    @Attribute(.unique)
    let id: Int
    let title: String
    
    var watched: Bool
    
    init(id: Int, title: String, watched: Bool = false) {
        self.id = id
        self.title = title
        
        self.watched = watched
    }
}
