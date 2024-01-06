//
//  TVBuddyApp.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import os
import SwiftData
import SwiftUI
import TMDb

@main
struct TVBuddyApp: App {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TVBuddyApp.self)
    )
    
    @StateObject private var searchStore = SearchStore()

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
            TVBuddyApp.logger.error("Failed to configure SwiftData container: \(error.localizedDescription)")
            fatalError("Failed to configure SwiftData container.")
        }
    }

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(searchStore)
                .onAppear(perform: {
                    Task(priority: .background) {
                        await updateMedia()
                    }
                })
        }
        .modelContainer(container)
    }
    
    func updateMedia() async {
        TVBuddyApp.logger.info("Trying to update media items")
        
        let lastUpdate = UserDefaults.standard.double(forKey: "LastMediaUpdate")
        if Date().timeIntervalSince1970 - lastUpdate < 60 * 60 * 6 {
            TVBuddyApp.logger.info("Last update of media items was within the last 6 hours")
            return
        }
        
        await MovieActor(modelContainer: container).updateMovies()
        await TVShowActor(modelContainer: container).updateTVShows()
        
        TVBuddyApp.logger.info("Finished updating media items")
    }
}
