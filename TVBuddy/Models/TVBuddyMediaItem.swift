//
//  TVBuddyMediaItem.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import Foundation
import TMDb
import SwiftUI

protocol TVBuddyMediaItem: Identifiable, Equatable, Hashable {
    var id: Int { get }
    var name: String { get }
    
    associatedtype T: View
    @ViewBuilder var detailView: T { get }
    
    func getPosterURL() async -> URL?
}

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

extension TVBuddyTVShow: TVBuddyMediaItem {
    var detailView: some View {
        TVShowView(id: self.id)
    }
    
    func getPosterURL() async -> URL? {
        await TVStore.shared.poster(withID: self.id)
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

extension TVSeries: TVBuddyMediaItem {
    var detailView: some View {
        TVShowView(id: self.id)
    }
    
    func getPosterURL() async -> URL? {
        await TVStore.shared.poster(withID: self.id)
    }
}
