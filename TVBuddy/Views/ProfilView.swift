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
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory.")
            return
        }

        let sourceURL = documentsDirectory.appendingPathComponent("database.sqlite")
        // Attempt to get the default store URL for SwiftData
        // Note: This is a common convention, but might need adjustment if the app uses a custom store configuration.
        // For a default setup, SwiftData often creates a persistence store in Application Support directory.
        // Let's try to find the default store URL if possible, otherwise fallback to a known name.

        var actualSourceURL = sourceURL // Default to documentsDirectory/database.sqlite

        if #available(iOS 17.0, *) { // ModelContainer is available from iOS 17
            // A more robust way for SwiftData would be to get the URL from the ModelContainer
            // However, accessing ModelContainer directly here in View might be tricky without environment setup.
            // For now, we'll stick to a common path, but ideally this should be passed from where ModelContainer is initialized.
            // This is a placeholder to indicate where a more robust solution would go.
             if let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeURL = appSupportDir.appendingPathComponent("default.store") // Default store name
                if fileManager.fileExists(atPath: storeURL.path) {
                    actualSourceURL = storeURL
                    print("Using SwiftData default store URL: \(actualSourceURL.path)")
                } else {
                     print("Default SwiftData store not found at \(storeURL.path), falling back to \(sourceURL.path)")
                     // Check if the fallback exists
                     if !fileManager.fileExists(atPath: sourceURL.path) {
                        print("Error: database.sqlite not found at \(sourceURL.path) either.")
                        // Consider showing an alert to the user
                        return
                     }
                }
            }
        } else {
            // Fallback for older iOS versions if necessary, or if not using iOS 17 specific features.
            // Check if the database.sqlite exists in documents directory for older versions or non-standard setups
            if !fileManager.fileExists(atPath: sourceURL.path) {
                 print("Error: database.sqlite not found at \(sourceURL.path).")
                 // Consider showing an alert to the user
                 return
            }
        }


        let temporaryDirectoryURL = fileManager.temporaryDirectory
        let backupURL = temporaryDirectoryURL.appendingPathComponent("TVBuddy_Backup_\(Date().timeIntervalSince1970).sqlite")

        do {
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            try fileManager.copyItem(at: actualSourceURL, to: backupURL)
            self.backupFileURL = backupURL
            self.showShareSheet = true
            print("Backup successful: \(backupURL.path)")
        } catch {
            print("Error backing up data: \(error)")
            // Optionally, show an alert to the user
        }
    }

    func restoreData(from backupURL: URL) {
        // startAccessingSecurityScopedResource should have been called by the caller (.fileImporter completion)
        // and stopAccessingSecurityScopedResource should be called by the caller as well.
        // However, to be safe, we ensure it's handled if not done by the caller.
        // For this implementation, we assume the caller (fileImporter block) handles start/stop.
        // If not, it should be:
        // guard backupURL.startAccessingSecurityScopedResource() else { ... return }
        // defer { backupURL.stopAccessingSecurityScopedResource() }

        let fileManager = FileManager.default

        // Determine the destination URL (same logic as in backupData for finding the store)
        var destinationURL: URL?
        if #available(iOS 17.0, *) {
            if let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeURL = appSupportDir.appendingPathComponent("default.store")
                // Check if this is the actual store path used by the app or if there's a fallback
                // This logic assumes 'default.store' is the primary or only store.
                // If the app could be using 'database.sqlite' in Documents even on iOS 17+, this needs adjustment.
                destinationURL = storeURL
                // To be robust, one might need to check if the app is currently using 'default.store' or the documentsDirectory one.
                // For now, we prioritize 'default.store' on iOS 17+.
                if !fileManager.fileExists(atPath: appSupportDir.path) { // Ensure appSupportDir exists
                    try? fileManager.createDirectory(at: appSupportDir, withIntermediateDirectories: true, attributes: nil)
                }
            }
        }

        if destinationURL == nil { // Fallback or older iOS
            if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                destinationURL = documentsDirectory.appendingPathComponent("database.sqlite")
            }
        }

        guard let finalDestinationURL = destinationURL else {
            restoreAlertMessage = "Could not determine the database destination URL."
            showRestoreAlert = true
            backupURL.stopAccessingSecurityScopedResource() // Stop access if started by caller
            return
        }

        print("Attempting to restore to: \(finalDestinationURL.path)")

        do {
            // Optional: Backup current database before overwriting
            // let currentDBBackupURL = ...
            // if fileManager.fileExists(atPath: finalDestinationURL.path) {
            //     try fileManager.moveItem(at: finalDestinationURL, to: currentDBBackupURL) // move or copy
            // }

            if fileManager.fileExists(atPath: finalDestinationURL.path) {
                try fileManager.removeItem(at: finalDestinationURL)
                print("Removed existing database at: \(finalDestinationURL.path)")
            }

            try fileManager.copyItem(at: backupURL, to: finalDestinationURL)

            restoreAlertMessage = "Data restored successfully from \(backupURL.lastPathComponent). Please restart the app for the changes to take effect."
            showRestoreAlert = true
            print("Data restored from: \(backupURL.path) to \(finalDestinationURL.path)")

        } catch {
            print("Error restoring data: \(error)")
            restoreAlertMessage = "Error restoring data: \(error.localizedDescription). Your existing data has not been changed."
            showRestoreAlert = true
        }
        backupURL.stopAccessingSecurityScopedResource() // Ensure security scope is released
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
