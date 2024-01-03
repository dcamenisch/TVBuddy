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
            TVBuddyApp.logger.error("Failed to configure SwiftData container: \(error.localizedDescription)")
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
                .onAppear(perform: {
                    Task(priority: .background) {
                        await updateMedia()
                    }
                })
        }
        .modelContainer(container)
    }
    
    func updateMedia() async {
        do {
            TVBuddyApp.logger.info("Trying to update media items")
            
            let context = ModelContext(container)
            
            let now = Date.now
            let past = Date.distantPast
            let future = Date.distantFuture
            
            let movies = try context.fetch(FetchDescriptor<TVBuddyMovie>(predicate: #Predicate<TVBuddyMovie> {$0.releaseDate ?? future >= now}))
            for movie in movies {
                if let _movie = await movieStore.movie(withID: movie.id) {
                    movie.update(movie: _movie)
                    TVBuddyApp.logger.info("Updated movie: \(_movie.title)")
                }
            }
                        
            let tvShows = try context.fetch(FetchDescriptor<TVBuddyTVShow>())
            for tvShow in tvShows {
                if let _tvShow = await tvStore.show(withID: tvShow.id) {
                    if tvShow.lastAirDate ?? past < _tvShow.lastAirDate ?? future {
                        tvShow.update(tvShow: _tvShow)
                        TVBuddyApp.logger.info("Updated tv show: \(_tvShow.name)")
                                                                        
                        for season in _tvShow.seasons ?? [] {
                            if let _season = await tvStore.season(season.seasonNumber, forTVSeries: _tvShow.id) {
                                for episode in _season.episodes ?? [] {
                                    if !tvShow.episodes.contains(where: {$0.seasonNumber == episode.seasonNumber && $0.episodeNumber == episode.episodeNumber}) {
                                        tvShow.episodes.append(TVBuddyTVEpisode(episode: episode))
                                        tvShow.finishedWatching = false
                                        TVBuddyApp.logger.info("Added new episodes for tv show: \(_tvShow.name)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
                        
            let episodes = try context.fetch(FetchDescriptor<TVBuddyTVEpisode>(predicate: #Predicate<TVBuddyTVEpisode> {$0.airDate ?? future >= now}))
            for episode in episodes {
                if let _episode = await tvStore.episode(episode.episodeNumber, season: episode.seasonNumber, forTVSeries: episode.tvShow?.id ?? 0) {
                    episode.update(episode: _episode)
                    TVBuddyApp.logger.info("Updated episodes: \(_episode.name)")
                }
            }
            
            try context.save()
            TVBuddyApp.logger.info("Finished updating media items")
        } catch {
            TVBuddyApp.logger.error("\(error.localizedDescription)")
        }
    }
}
