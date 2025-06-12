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

    // Constants for the restore process, must match ProfilView
    private let pendingRestoreKey = "pendingRestoreFilePath"
    private let incomingRestoreFilename = "incoming_restore.sqlite"


    init() {
        // Perform restore check BEFORE ModelContainer is initialized
        handlePendingRestore()

        Task {
            AppConstants.apiConfiguration = try await AppConstants.tmdbClient.configurations.apiConfiguration()
        }
        
        do {
            let schema = Schema(TVBuddyMediaSchema.models)
            // IMPORTANT: This is the main database URL the app uses.
            // The restore process MUST target this exact URL.
            let mainDatabaseURL = URL.documentsDirectory.appending(path: "database.sqlite")
            TVBuddyApp.logger.info("Main database URL is: \(mainDatabaseURL.path)")

            let config = ModelConfiguration(schema: schema, url: mainDatabaseURL)
            container = try ModelContainer(
                for: schema,
                migrationPlan: TVBuddyMediaMigrationPlan.self,
                configurations: config
            )
            TVBuddyApp.logger.info("Successfully configured SwiftData container.")
        } catch {
            TVBuddyApp.logger.error("Failed to configure SwiftData container: \(error.localizedDescription)")
            fatalError("Failed to configure SwiftData container.")
        }
    }

    private func handlePendingRestore() {
        TVBuddyApp.logger.info("Checking for pending data restore operation...")
        let userDefaults = UserDefaults.standard
        let fileManager = FileManager.default

        guard let pendingRestorePath = userDefaults.string(forKey: pendingRestoreKey) else {
            TVBuddyApp.logger.info("No pending restore path found in UserDefaults.")
            return
        }

        let incomingFileToRestoreFromURL = URL(fileURLWithPath: pendingRestorePath)
        TVBuddyApp.logger.info("Pending restore path found: \(pendingRestorePath)")

        // IMPORTANT: Determine the main database URL. This MUST match the URL used by ModelContainer.
        // The current ModelContainer setup explicitly uses "database.sqlite" in Documents.
        let mainDatabaseURL = URL.documentsDirectory.appending(path: "database.sqlite")
        // The ProfilView's backup/restore logic might also consider "default.store" in Application Support for iOS 17+.
        // However, the critical part for THIS function is to replace the file that ModelContainer WILL load.
        // If ModelContainer loads from App Support/default.store, then mainDatabaseURL here must point to that.
        // Based on current TVBuddyApp.swift, it's Documents/database.sqlite.

        // Defer removing the UserDefaults key until the end of this function, cleaning up regardless of outcome.
        // However, if something goes catastrophically wrong early, it might not be removed.
        // A more robust approach is to remove it only on clear success or clear, unrecoverable failure.
        // For now, we remove it if the incoming file doesn't exist, or after processing.

        if !fileManager.fileExists(atPath: incomingFileToRestoreFromURL.path) {
            TVBuddyApp.logger.error("Error: Pending restore file does not exist at \(incomingFileToRestoreFromURL.path). Clearing pending restore key.")
            userDefaults.removeObject(forKey: pendingRestoreKey)
            return
        }

        TVBuddyApp.logger.info("Pending restore file exists at \(incomingFileToRestoreFromURL.path). Main DB target is \(mainDatabaseURL.path).")

        do {
            // 1. Remove current main database file (if it exists)
            if fileManager.fileExists(atPath: mainDatabaseURL.path) {
                TVBuddyApp.logger.info("Attempting to remove existing main database at \(mainDatabaseURL.path)...")
                try fileManager.removeItem(at: mainDatabaseURL)
                TVBuddyApp.logger.info("Successfully removed existing main database.")
            } else {
                TVBuddyApp.logger.info("No existing main database found at \(mainDatabaseURL.path). Skipping removal.")
            }

            // 2. Copy (or move) incoming_restore.sqlite to become the new main database file
            TVBuddyApp.logger.info("Attempting to copy \(incomingFileToRestoreFromURL.path) to \(mainDatabaseURL.path)...")
            try fileManager.copyItem(at: incomingFileToRestoreFromURL, to: mainDatabaseURL)
            TVBuddyApp.logger.info("Successfully copied incoming restore file to main database location.")

            // 3. If both remove and copy/move are successful:
            TVBuddyApp.logger.info("Restore successful! Removing incoming restore file and UserDefaults key.")
            try fileManager.removeItem(at: incomingFileToRestoreFromURL) // Remove the now processed incoming_restore.sqlite
            userDefaults.removeObject(forKey: pendingRestoreKey) // Clear the pending restore flag
            // Optionally: Set a flag for "Restore Succeeded" to inform user on next launch if desired.
            // userDefaults.set(true, forKey: "restoreCompletedSuccessfullyAlert")

        } catch {
            TVBuddyApp.logger.error("CRITICAL ERROR during restore process: \(error.localizedDescription)")
            // At this point, the database might be in an inconsistent state.
            // It's advisable to remove the incoming_restore.sqlite to prevent repeated failed attempts.
            // Also remove the pending key.
            TVBuddyApp.logger.info("Attempting to clean up after critical restore error...")
            if fileManager.fileExists(atPath: incomingFileToRestoreFromURL.path) {
                do {
                    try fileManager.removeItem(at: incomingFileToRestoreFromURL)
                    TVBuddyApp.logger.info("Cleaned up (removed) incoming restore file.")
                } catch {
                    TVBuddyApp.logger.error("Failed to clean up incoming restore file: \(error.localizedDescription)")
                }
            }
            userDefaults.removeObject(forKey: pendingRestoreKey)
            TVBuddyApp.logger.info("Removed pending restore key after error.")
            // Optionally, set another UserDefaults flag to inform the user on next full app load that the restore attempt failed.
            // userDefaults.set(true, forKey: "restoreFailedAlert")
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
