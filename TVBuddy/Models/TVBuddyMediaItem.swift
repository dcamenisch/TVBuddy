//
//  TVBuddyMediaItem.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import Foundation
import TMDb
import SwiftUI

protocol TVBuddyMediaItem {
    var id: Int { get }
    var name: String { get }
    
    func getPosterURL() async -> URL?
    func getDetailView() -> any View
}

extension TVBuddyMovie: TVBuddyMediaItem {
    var name: String {
        self.title
    }
    
    func getPosterURL() async -> URL? {
        await MovieStore.shared.poster(withID: self.id)
    }
    
    func getDetailView() -> any View {
        MovieView(id: self.id)
    }
}

extension TVBuddyTVShow: TVBuddyMediaItem {
    func getPosterURL() async -> URL? {
        await TVStore.shared.poster(withID: self.id)
    }
    
    func getDetailView() -> any View {
        TVShowView(id: self.id)
    }
}

extension Movie: TVBuddyMediaItem {
    var name: String {
        self.title
    }
    
    func getPosterURL() async -> URL? {
        await MovieStore.shared.poster(withID: self.id)
    }
    
    func getDetailView() -> any View {
        MovieView(id: self.id)
    }
}

extension TVSeries: TVBuddyMediaItem {
    func getPosterURL() async -> URL? {
        await TVStore.shared.poster(withID: self.id)
    }
    
    func getDetailView() -> any View {
        TVShowView(id: self.id)
    }
}
