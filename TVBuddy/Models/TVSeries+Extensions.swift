//
//  TVSeries+Extensions.swift
//  TVBuddy
//
//  Created by Danny on 07.01.2024.
//

import Foundation
import SwiftUI
import TMDb

extension TVSeries {
    var metadata: [String] {
        var items = [String]()

        if let releaseDate = self.firstAirDate {
            items.append(DateFormatter.year.string(from: releaseDate))
        }

        if let status = self.status {
            items.append(status)
        }

        return items
    }
}

extension TVSeries: TVBuddyMediaItem {
    var detailView: some View {
        TVShowView(id: self.id)
    }
    
    func getPosterURL() async -> URL? {
        await TVStore.shared.poster(withID: self.id)
    }
}
