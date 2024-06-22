//
//  TVBuddyTVShow+Extensions.swift
//  TVBuddy
//
//  Created by Danny on 07.01.2024.
//

import Foundation
import SwiftUI

extension TVBuddyTVShow: TVBuddyMediaItem {
    var detailView: some View {
        TVShowView(id: self.id)
    }
    
    func getPosterURL() async -> URL? {
        await TVStore.shared.posters(id: self.id).first
    }
}
