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
    
    var container: ModelContainer

    init() {
        let tmdbConfiguration = TMDbConfiguration(apiKey: AppConstants.apiKey)
        TMDb.configure(tmdbConfiguration)

        Task {
            AppConstants.apiConfiguration = try await AppConstants.configurationService.apiConfiguration()
        }
        
        do {
            let schema = Schema(TVBuddyMediaSchema.models)
            let config = ModelConfiguration(schema: schema)
            container = try ModelContainer(
                for: schema,
                migrationPlan: TVBuddyMediaMigrationPlan.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to configure SwiftData container.")
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
        .modelContainer(container)
    }
}
