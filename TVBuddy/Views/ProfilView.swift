//
//  ProfilView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftData
import SwiftUI
import TMDb
import UniformTypeIdentifiers // Required for UTType

struct ProfilView: View {

    @Query
    private var alldMovies: [TVBuddyMovie]

    @Query(filter: #Predicate<TVBuddyMovie> { $0.watched })
    private var watchedMovies: [TVBuddyMovie]

    @Query(filter: #Predicate<TVBuddyTVShow> { $0.finishedWatching })
    private var watchedTVShows: [TVBuddyTVShow]

    @Query(filter: #Predicate<TVBuddyTVShow> { $0.isArchived })
    private var archivedTVShows: [TVBuddyTVShow]

    @Query(filter: #Predicate<TVBuddyTVEpisode> { !($0.tvShow?.isArchived ?? false) })
    private var allTVEpisodes: [TVBuddyTVEpisode]

    @Query(filter: #Predicate<TVBuddyTVEpisode> { $0.watched })
    private var watchedTVEpisodes: [TVBuddyTVEpisode]

    private var watchlistProgress: CGFloat {
        Double(watchedMovies.count + watchedTVEpisodes.count)
            / Double(alldMovies.count + allTVEpisodes.count)
    }

    @State private var showShareSheet = false
    @State private var backupFileURL: URL?
    @State private var showDocumentPicker = false
    @State private var showRestoreAlert = false
    @State private var restoreAlertMessage = ""

    var body: some View {
        NavigationView {
            List {
                // Watchlist Progress Section
                Section {
                    VStack(spacing: 16) {
                    Text("Watchlist Progress")
                        .font(.title.bold())
                        .foregroundColor(.primary)

                        CircularProgressBar(progress: watchlistProgress, strokeWidth: 20) {
                            VStack {
                                Text("\(String(format: "%.2f", watchlistProgress * 100))%")
                                    .font(.largeTitle.bold())

                                Text("of your watchlist completed.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .frame(width: 200, height: 200)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                }

                // Stats Section
                Section {
                    HStack {
                        StatCard(title: "Watched TV Shows", value: watchedTVShows.count)
                        StatCard(title: "Watched Episodes", value: watchedTVEpisodes.count)
                    }

                    StatCard(title: "Watched Movies", value: watchedMovies.count)
                }

                // Media Collections
                Section {
                    MediaCollection(
                        title: "Watched Movies (\(watchedMovies.count))",
                        media: watchedMovies
                    ).id(watchedMovies)

                    MediaCollection(
                        title: "Watched TV Shows (\(watchedTVShows.count))",
                        media: watchedTVShows
                    ).id(watchedTVShows)

                    MediaCollection(
                        title: "Archived TV Shows (\(archivedTVShows.count))",
                        media: archivedTVShows
                    ).id(archivedTVShows)
                }

                Section(header: Text("Data Management")) {
                    Button(action: {
                        backupData()
                    }) {
                        Label("Backup Data", systemImage: "arrow.down.doc")
                    }

                    Button(action: {
                        self.showDocumentPicker = true
                    }) {
                        Label("Restore Data", systemImage: "arrow.up.doc")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showShareSheet) {
                if let url = backupFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .fileImporter(
                isPresented: $showDocumentPicker,
                allowedContentTypes: [UTType.database], // Using generic UTType.database
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let selectedURL = urls.first else {
                        restoreAlertMessage = "Could not get the selected file."
                        showRestoreAlert = true
                        return
                    }
                    // Ensure the app has permission to access the file.
                    guard selectedURL.startAccessingSecurityScopedResource() else {
                        restoreAlertMessage = "Permission denied. Could not access the selected backup file. Please ensure it's stored locally and accessible."
                        showRestoreAlert = true
                        // No need to call stopAccessingSecurityScopedResource if startAccessingSecurityScopedResource returns false.
                        return
                    }
                    restoreData(from: selectedURL)
                    // Deferring stopAccessingSecurityScopedResource to after restoreData completes or errors out.
                    // This is handled within restoreData or just before this block ends if not passed.
                    // However, for clarity and safety, it's better if restoreData handles it.
                    // For this structure, we will call it here after restoreData finishes.
                    // selectedURL.stopAccessingSecurityScopedResource() // This will be handled in restoreData
                case .failure(let error):
                    print("Error picking document: \(error.localizedDescription)")
                    restoreAlertMessage = "Failed to pick the backup file: \(error.localizedDescription)"
                    showRestoreAlert = true
                }
            }
            .alert(isPresented: $showRestoreAlert) {
                Alert(title: Text("Restore Information"), message: Text(restoreAlertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func backupData() {
        let fileManager = FileManager.default

        // Determine the source URL of the database
        var sourceDatabaseURL: URL?
        if #available(iOS 17.0, *) {
            if let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeURL = appSupportDir.appendingPathComponent("default.store")
                if fileManager.fileExists(atPath: storeURL.path) {
                    sourceDatabaseURL = storeURL
                    print("Identified source database (iOS 17+): \(storeURL.path)")
                }
            }
        }

        // Fallback or if not found in App Support
        if sourceDatabaseURL == nil {
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let docStoreURL = documentsDirectory.appendingPathComponent("database.sqlite")
                if fileManager.fileExists(atPath: docStoreURL.path) {
                    sourceDatabaseURL = docStoreURL
                    print("Identified source database (fallback/pre-iOS 17): \(docStoreURL.path)")
                }
            }
        }

        // Check if source database exists
        guard let actualSourceURL = sourceDatabaseURL else {
            print("Error: Source database file not found. Looked in Application Support (default.store) and Documents (database.sqlite).")
            // self.backupAlertMessage = "Error: Database file not found to backup." // Example for an alert
            // self.showBackupAlert = true // Example for an alert
            return
        }

        // Ensure it really exists (though guard above should suffice if sourceDatabaseURL is only set if fileExists)
        if !fileManager.fileExists(atPath: actualSourceURL.path) {
            print("Error: Source database file confirmed missing at \(actualSourceURL.path) just before copy.")
            // self.backupAlertMessage = "Error: Database file disappeared before backup." // Example for an alert
            // self.showBackupAlert = true // Example for an alert
            return
        }

        let temporaryDirectoryURL = fileManager.temporaryDirectory
        let backupFileName = "TVBuddy_Backup_\(String(format: "%.0f", Date().timeIntervalSince1970)).sqlite"
        let backupURL = temporaryDirectoryURL.appendingPathComponent(backupFileName)

        do {
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
                print("Removed existing temporary backup file at: \(backupURL.path)")
            }
            try fileManager.copyItem(at: actualSourceURL, to: backupURL)
            print("Successfully copied database from \(actualSourceURL.path) to \(backupURL.path)")

            // Ensure backupURL is set before showing the sheet
            self.backupFileURL = backupURL
            self.showShareSheet = true // Now it's safe to set this
            print("Backup successful, file ready at: \(backupURL.path). Share sheet will be shown.")

        } catch {
            print("Error backing up data: \(error.localizedDescription)")
            // self.backupAlertMessage = "Error backing up data: \(error.localizedDescription)" // Example for an alert
            // self.showBackupAlert = true // Example for an alert
        }
    }

    // Constants for the restore process
    private let incomingRestoreFilename = "incoming_restore.sqlite"
    private let pendingRestoreKey = "pendingRestoreFilePath"

    func restoreData(from selectedBackupURL: URL) {
        // selectedBackupURL is the URL from the fileImporter, e.g., a file in Inbox or iCloud.
        // startAccessingSecurityScopedResource() should have been called by the fileImporter's completion handler.

        let fileManager = FileManager.default

        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            restoreAlertMessage = "Error: Could not access app's documents directory."
            showRestoreAlert = true
            selectedBackupURL.stopAccessingSecurityScopedResource()
            return
        }

        let targetIncomingRestoreURL = documentsDirectory.appendingPathComponent(incomingRestoreFilename)

        do {
            // If a previous incoming_restore.sqlite exists, remove it.
            if fileManager.fileExists(atPath: targetIncomingRestoreURL.path) {
                try fileManager.removeItem(at: targetIncomingRestoreURL)
                print("Removed existing incoming restore file: \(targetIncomingRestoreURL.path)")
            }

            // Copy the selected backup file to the well-known "incoming_restore.sqlite" path.
            // This copy operation is crucial. The selectedBackupURL might be in a location not accessible at next app launch (e.g. iCloud temp).
            // By copying it into our app's documents directory, we ensure it's available.
            try fileManager.copyItem(at: selectedBackupURL, to: targetIncomingRestoreURL)
            print("Successfully copied selected backup from \(selectedBackupURL.path) to \(targetIncomingRestoreURL.path)")

            // If copy is successful, store the path of this "incoming_restore.sqlite" in UserDefaults.
            UserDefaults.standard.set(targetIncomingRestoreURL.path, forKey: pendingRestoreKey)
            print("Saved pending restore path to UserDefaults: \(targetIncomingRestoreURL.path)")

            // Update alert message to instruct user to restart.
            restoreAlertMessage = "Backup file prepared successfully. Please CLOSE and RESTART the app to complete the restore process. Your current data is still active until you restart."
            showRestoreAlert = true

        } catch {
            print("Error during restore preparation: \(error.localizedDescription)")
            restoreAlertMessage = "Error preparing restore: \(error.localizedDescription). Please try again."
            showRestoreAlert = true
            // Ensure no pending restore path is saved if any step failed.
            UserDefaults.standard.removeObject(forKey: pendingRestoreKey)
            // Attempt to clean up partial incoming file if it exists
            if fileManager.fileExists(atPath: targetIncomingRestoreURL.path) {
                try? fileManager.removeItem(at: targetIncomingRestoreURL)
            }
        }

        // Release security-scoped access to the original selected backup URL.
        selectedBackupURL.stopAccessingSecurityScopedResource()
    }
}

// MARK: - Reusable StatCard View
struct StatCard: View {
    let title: String
    let value: Int

    var body: some View {
        VStack {
            Text("\(value)")
                .font(.largeTitle.bold())

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Helper struct for ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update here
    }
}
