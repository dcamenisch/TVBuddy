//
//  TVBuddyApp.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftData
import SwiftUI
import TMDb

@main
struct TVBuddyApp: App {
    @StateObject private var movieStore = MovieStore()
    @StateObject private var personStore = PersonStore()
    @StateObject private var searchStore = SearchStore()
    @StateObject private var tvStore = TVStore()

    init() {
        let tmdbConfiguration = TMDbConfiguration(apiKey: AppConstants.apiKey)
        TMDb.configure(tmdbConfiguration)

        Task {
            AppConstants.apiConfiguration = try await AppConstants.configurationService.apiConfiguration()
        }
    }

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .colorScheme(.dark)
                .environmentObject(movieStore)
                .environmentObject(personStore)
                .environmentObject(searchStore)
                .environmentObject(tvStore)
        }
        .modelContainer(for: [TVBuddyMovie.self, TVBuddyTVShow.self, TVBuddyTVEpisode.self])
    }
}
