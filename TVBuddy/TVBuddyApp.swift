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
    
    var container: ModelContainer

    init() {
        Task {
            AppConstants.apiConfiguration = try await AppConstants.tmdbClient.configurations.apiConfiguration()
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
        
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "LastMediaUpdate")
        TVBuddyApp.logger.info("Finished updating media items")
    }
}
