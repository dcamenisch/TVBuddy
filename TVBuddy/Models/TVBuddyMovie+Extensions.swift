//
//  TVBuddyMovie+Extensions.swift
//  TVBuddy
//
//  Created by Danny on 07.01.2024.
//

import Foundation
import SwiftUI

extension TVBuddyMovie: TVBuddyMediaItem {
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
