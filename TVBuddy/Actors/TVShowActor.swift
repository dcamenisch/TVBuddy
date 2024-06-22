//
//  TVShowActor.swift
//  TVBuddy
//
//  Created by Danny on 06.01.2024.
//

import os
import SwiftData
import SwiftUI
import TMDb

/// An actor responsible for managing TV show-related operations in the TVBuddy app.
/// Utilizes concurrency to safely access and modify TV show data.
@ModelActor
actor TVShowActor {
    /// Logger for the TVShowActor class, used to log information and errors.
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TVShowActor.self)
    )
    
    /// Inserts a new TV series into the database along with its episodes.
    /// - Parameters:
    ///   - id: The TMDb identifier of the TV series to insert.
    ///   - watched: A Boolean value indicating whether the TV series has been watched.
    ///   - isFavorite: A Boolean value indicating whether the TV series is marked as a favorite.
    ///   - episodeID: An optional episode ID to mark a specific episode as watched. Defaults to -1.
    func insertTVSeries(id: TVSeries.ID, watched: Bool, isFavorite: Bool, episodeID: TVEpisode.ID = -1) async {
        do {
            let series = await TVStore.shared.show(withID: id)
            
            guard let series = series else { return }
            let tvbSeries = TVBuddyTVShow(
                tvShow: series,
                startedWatching: watched,
                finishedWatching: watched,
                isFavorite: isFavorite
            )
            
            modelContext.insert(tvbSeries)
            try modelContext.save()
            
            let episodes = await withTaskGroup(of: TVSeason?.self, returning: [TVEpisode].self) { group in
                for season in series.seasons ?? [] {
                    group.addTask {
                        await TVStore.shared.season(season.seasonNumber, forTVSeries: id)
                    }
                }
            
                var childTaskResults = [TVEpisode]()
                for await result in group {
                    childTaskResults.append(contentsOf: result?.episodes ?? [])
                }
            
                return childTaskResults
            }.compactMap {
                TVBuddyTVEpisode(episode: $0, watched: watched)
            }
            
            tvbSeries.episodes.append(contentsOf: episodes)
            
            TVShowActor.logger.info("Inserted tv series \(series.name) with \(episodes.count) episodes")
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Deletes a TV show from the database.
    /// - Parameter id: The TMDb identifier of the TV show to delete.
    func deleteTVShow(id: TVSeries.ID) async {
        do {
            let predicate = #Predicate<TVBuddyTVShow> {$0.id == id}
            let tvbSeries = try modelContext.fetch(
                FetchDescriptor<TVBuddyTVShow>(predicate: predicate)
            ).first
            
            guard let tvbSeries = tvbSeries else { return }
            
            modelContext.delete(tvbSeries)
            try modelContext.save()
            
            TVShowActor.logger.info("Deleted tv show \(tvbSeries.name)")
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }
    
    /// Updates the details of all TV shows and episodes in the database.
    func updateTVShows() async {
        do {
            // Update the TV Series
            let tvbTVSeries = try modelContext.fetch(FetchDescriptor<TVBuddyTVShow>())
            for tvbSeries in tvbTVSeries { await updateTVSeries(tvbSeries) }
            
            // Update the TV Episodes
            let now = Date.now
            let future = Date.distantFuture
            let predicate = #Predicate<TVBuddyTVEpisode> {$0.airDate ?? future >= now}
            let tvbEpisodes = try modelContext.fetch(
                FetchDescriptor<TVBuddyTVEpisode>(predicate: predicate)
            )
            
            for tvbEpisode in tvbEpisodes {
                let episode = await TVStore.shared.episode(
                    tvbEpisode.episodeNumber,
                    season: tvbEpisode.seasonNumber,
                    forTVSeries: tvbEpisode.tvShow?.id ?? 0
                )
                
                guard let episode = episode else { continue }
                tvbEpisode.update(episode: episode)
            }
            
            try modelContext.save()
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "LastMediaUpdate")
            
            TVShowActor.logger.info("Updated \(tvbTVSeries.count) tv shows")
            TVShowActor.logger.info("Updated \(tvbEpisodes.count) episodes")
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }
    
    /// Updates a single TV series with the latest details and episodes.
    /// - Parameter tvbSeries: The TVBuddyTVShow object to update.
    private func updateTVSeries(_ tvbSeries: TVBuddyTVShow) async {
        let series = await TVStore.shared.show(withID: tvbSeries.id)
                        
        guard let series = series, series.isInProduction ?? true else { return }
        
        tvbSeries.update(tvShow: series)
        for season in series.seasons ?? [] {
            let season = await TVStore.shared.season(season.seasonNumber, forTVSeries: series.id)
            
            guard let season = season else { continue }
            
            season.episodes?.forEach({ episode in
                if !tvbSeries.episodes.contains(where: {
                    $0.seasonNumber == episode.seasonNumber && $0.episodeNumber == episode.episodeNumber
                }) {
                    
                    tvbSeries.episodes.append(TVBuddyTVEpisode(episode: episode))
                    tvbSeries.checkWatching()
                }
            })
        }
    }
}
