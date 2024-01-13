//
//  Movie+Extensions.swift
//  TVBuddy
//
//  Created by Danny on 07.01.2024.
//

import Foundation
import SwiftUI
import TMDb

extension Movie {
    var metadata: [String] {
        var items = [String]()
        
        if let runtime = self.runtime, runtime > 0 {
            let hours = Int(runtime / 60)
            let minutes = Int(runtime % 60)
            
            if hours == 0 {
                items.append("\(minutes) min")
            } else {
                items.append("\(hours) hr \(minutes) min")
            }
        }
        
        if let releaseDate = self.releaseDate {
            items.append(DateFormatter.year.string(from: releaseDate))
        }
        
        if let status = self.status {
            items.append(status.rawValue)
        }
        
        return items
    }
}

extension Movie: TVBuddyMediaItem {
    var name: String {
        self.title
    }
    
    var detailView: some View {
        MovieView(id: self.id)
    }
    
    func getPosterURL() async -> URL? {
        await MovieStore.shared.poster(withID: self.id)
    }
}
