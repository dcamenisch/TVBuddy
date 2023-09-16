//
//  tvBuddyApp.swift
//  tvBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI
import SwiftData

@main
struct TVBuddyApp: App {
    @StateObject private var movieStore  = MovieStore()
    @StateObject private var personStore = PersonStore()
    @StateObject private var searchStore = SearchStore()
    @StateObject private var tvStore     = TVStore()
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .colorScheme(.dark)
                .environmentObject(movieStore)
                .environmentObject(personStore)
                .environmentObject(searchStore)
                .environmentObject(tvStore)
        }
        .modelContainer(for: [Movie.self, TVSeries.self, TVEpisode.self])
    }
}
