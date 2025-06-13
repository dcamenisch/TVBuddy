//
//  TVShowActor.swift
//  TVBuddy
//
//  Created by Danny on 06.01.2024.
//

import SwiftData
import SwiftUI
import TMDb
import os

/// An actor responsible for managing TV show-related operations in the TVBuddy app.
/// Utilizes concurrency to safely access and modify TV show data.
@ModelActor
actor TVShowActor {
    /// Logger for the TVShowActor class, used to log information and errors.
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TVShowActor.self)
    )

    func toggleShowWatchlist(showID: TVSeries.ID) async {
        let predicate = #Predicate<TVBuddyTVShow> { $0.id == showID }
        do {
            if try modelContext.fetch(FetchDescriptor(predicate: predicate)).first != nil {
                await deleteTVShow(id: showID)
            } else {
                await addTVSeries(id: showID, finishedWatching: false, isFavorite: false)
            }
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }

    func toggleShowWatched(showID: TVSeries.ID) async {
        let predicate = #Predicate<TVBuddyTVShow> { $0.id == showID }
        do {
            if let existingTVSeries = try modelContext.fetch(FetchDescriptor(predicate: predicate))
                .first
            {
                existingTVSeries.toggleWatched()
                try modelContext.save()
                TVShowActor.logger.info(
                    "Toggled watched status for show \(existingTVSeries.name). Now: started=\(existingTVSeries.startedWatching), finished=\(existingTVSeries.finishedWatching)"
                )
            } else {
                await addTVSeries(id: showID, finishedWatching: true, isFavorite: false)
            }
        } catch {
            TVShowActor.logger.error(
                "Error toggling watched status for show ID \(showID): \(error.localizedDescription)"
            )
        }
    }

    func toggleShowFavorite(showID: TVSeries.ID) async {
        let predicate = #Predicate<TVBuddyTVShow> { $0.id == showID }
        do {
            if let existingTVSeries = try modelContext.fetch(FetchDescriptor(predicate: predicate))
                .first
            {
                existingTVSeries.isFavorite.toggle()
                try modelContext.save()

                TVShowActor.logger.info(
                    "Toggled favorite for show \(existingTVSeries.name) to \(existingTVSeries.isFavorite)."
                )
            } else {
                await addTVSeries(id: showID, finishedWatching: false, isFavorite: true)
            }
        } catch {
            TVShowActor.logger.error(
                "Error toggling favorite for show ID \(showID): \(error.localizedDescription)"
            )
        }
    }

    func toggleShowArchived(showID: TVSeries.ID) async {
        let predicate = #Predicate<TVBuddyTVShow> { $0.id == showID }
        do {
            if let existingTVSeries = try modelContext.fetch(FetchDescriptor(predicate: predicate))
                .first
            {
                existingTVSeries.isArchived.toggle()
                try modelContext.save()

                TVShowActor.logger.info(
                    "Toggled archived for show \(existingTVSeries.name) to \(existingTVSeries.isFavorite)."
                )
            }
        } catch {
            TVShowActor.logger.error(
                "Error toggling favorite for show ID \(showID): \(error.localizedDescription)"
            )
        }
    }

    func toggleSeasonWatched(showID: TVSeries.ID, seasonNumber: Int, watched: Bool) async {
        let predicate = #Predicate<TVBuddyTVShow> { $0.id == showID }
        do {
            if (try modelContext.fetch(FetchDescriptor(predicate: predicate)).first) == nil {
                await addTVSeries(id: showID, finishedWatching: false, isFavorite: false)
            }

            guard let show = try modelContext.fetch(FetchDescriptor(predicate: predicate)).first
            else {
                TVShowActor.logger.error(
                    "Failed to toggle season watched: Show not found for ID \(showID)"
                )
                return
            }

            let episodes = show.episodes.filter({ $0.seasonNumber == seasonNumber })
            if !episodes.isEmpty {
                for episode in episodes {
                    episode.toggleWatched()
                }
                try modelContext.save()
                TVShowActor.logger.info(
                    "Toggled watched for season \(seasonNumber) of show \(show.name) to \(watched)."
                )
            }
        } catch {
            TVShowActor.logger.error(
                "Error toggling season watched for S\(seasonNumber) of show ID \(showID): \(error.localizedDescription)"
            )
        }
    }

    func toggleEpisodeWatched(
        showID: TVSeries.ID,
        seasonNumber: Int,
        episodeNumber: Int,
        episodeID: TVEpisode.ID,
    ) async {
        let predicate = #Predicate<TVBuddyTVShow> { $0.id == showID }
        do {
            if (try modelContext.fetch(FetchDescriptor(predicate: predicate)).first) == nil {
                await addTVSeries(id: showID, finishedWatching: false, isFavorite: false)
            }

            guard let show = try modelContext.fetch(FetchDescriptor(predicate: predicate)).first
            else {
                TVShowActor.logger.error(
                    "Failed to toggle episode watched: Show not found for ID \(showID)"
                )
                return
            }

            if let episode = show.episodes.first(where: { $0.id == episodeID }) {
                episode.toggleWatched()
                try modelContext.save()
                TVShowActor.logger.info(
                    "Toggled watched for S\(seasonNumber)E\(episodeNumber) of show \(show.name) to \(episode.watched)."
                )
            } else {
                // Episode not found in existing show. This might indicate incomplete initial insertion or bad data.
                TVShowActor.logger.warning(
                    "Episode ID \(episodeID) (S\(seasonNumber)E\(episodeNumber)) not found in existing show \(show.name). Attempting to fetch and add."
                )

                if let episodeData = try? await TVStore.shared.episode(
                    episodeNumber,
                    season: seasonNumber,
                    forTVSeries: showID
                ) {
                    let newEpisode = TVBuddyTVEpisode(episode: episodeData, watched: true)
                    show.episodes.append(newEpisode)
                    show.checkWatching()
                    try modelContext.save()
                    TVShowActor.logger.info(
                        "Added missing episode S\(seasonNumber)E\(episodeNumber) to show \(show.name) and marked as watched."
                    )
                } else {
                    TVShowActor.logger.error(
                        "Failed to fetch details for missing episode S\(seasonNumber)E\(episodeNumber) for show \(show.name)."
                    )
                }
            }
        } catch {
            TVShowActor.logger.error(
                "Error toggling episode watched for S\(seasonNumber)E\(episodeNumber) of show ID \(showID): \(error.localizedDescription)"
            )
        }
    }

    /// Inserts a new TV series into the database along with its episodes.
    private func addTVSeries(
        id: TVSeries.ID,
        finishedWatching: Bool,
        isFavorite: Bool,
    ) async {
        do {
            guard let series = try? await TVStore.shared.show(withID: id) else {
                TVShowActor.logger.error("Failed to fetch series with ID \(id) from TVStore.")
                return
            }

            let tvbSeries = TVBuddyTVShow(
                tvShow: series,
                startedWatching: finishedWatching,
                finishedWatching: finishedWatching,
                isFavorite: isFavorite
            )

            modelContext.insert(tvbSeries)
            try modelContext.save()

            var allEpisodesForShow: [TVBuddyTVEpisode] = []
            if let seasons = series.seasons {
                for seasonSummary in seasons {
                    guard
                        let detailedSeason = try? await TVStore.shared.season(
                            seasonSummary.seasonNumber,
                            forTVSeries: id
                        )
                    else {
                        TVShowActor.logger.error(
                            "Failed to fetch season \(seasonSummary.seasonNumber) for TV series with ID \(id)"
                        )
                        continue
                    }

                    guard let episodesInSeason = detailedSeason.episodes else {
                        continue
                    }

                    for episodeData in episodesInSeason {
                        allEpisodesForShow.append(
                            TVBuddyTVEpisode(episode: episodeData, watched: finishedWatching)
                        )
                    }
                }
            }

            tvbSeries.episodes.append(contentsOf: allEpisodesForShow)
            try modelContext.save()

            TVShowActor.logger.info(
                "Inserted TV series \(series.name) with \(allEpisodesForShow.count) episodes."
            )
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }

    //// Deletes a TV show from the database.
    private func deleteTVShow(id: TVSeries.ID) async {
        do {
            let predicate = #Predicate<TVBuddyTVShow> { $0.id == id }
            let tvbSeries = try modelContext.fetch(FetchDescriptor(predicate: predicate)).first

            guard let tvbSeries = tvbSeries else {
                TVShowActor.logger.warning(
                    "Attempted to delete non-existent TV show with ID \(id)."
                )
                return
            }

            let seriesName = tvbSeries.name
            modelContext.delete(tvbSeries)
            try modelContext.save()

            TVShowActor.logger.info("Deleted TV show \(seriesName)")
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Updates the details of all TV shows and episodes in the database.
    func updateTVShows() async {
        do {
            // Update the TV Series
            let tvbTVSeries = try modelContext.fetch(FetchDescriptor<TVBuddyTVShow>())
            for tvbSeries in tvbTVSeries {
                do {
                    try await updateTVSeries(tvbSeries)
                } catch TMDbError.notFound {
                    TVShowActor.logger.error(
                        "TV series \(tvbSeries.name) not found, removing from database"
                    )
                    await deleteTVShow(id: tvbSeries.id)
                }
            }

            // Update the TV Episodes
            let now = Date.now
            let future = Date.distantFuture
            let predicate = #Predicate<TVBuddyTVEpisode> { $0.airDate ?? future >= now }
            let tvbEpisodes = try modelContext.fetch(
                FetchDescriptor<TVBuddyTVEpisode>(predicate: predicate)
            )

            for tvbEpisode in tvbEpisodes {
                let episode = try? await TVStore.shared.episode(
                    tvbEpisode.episodeNumber,
                    season: tvbEpisode.seasonNumber,
                    forTVSeries: tvbEpisode.tvShow?.id ?? 0
                )

                guard let episode = episode else {
                    TVShowActor.logger.error(
                        "TV episode \(tvbEpisode.episodeNumber), season \(tvbEpisode.seasonNumber) for TV series \(tvbEpisode.tvShow?.name ?? "") not found, removing from database"
                    )
                    modelContext.delete(tvbEpisode)
                    try modelContext.save()
                    continue
                }
                tvbEpisode.update(episode: episode)
            }

            try modelContext.save()

            TVShowActor.logger.info("Updated \(tvbTVSeries.count) tv shows")
            TVShowActor.logger.info("Updated \(tvbEpisodes.count) episodes")
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Updates a single TV series with the latest details and episodes.
    private func updateTVSeries(_ tvbSeries: TVBuddyTVShow) async throws {
        let series = try await TVStore.shared.show(withID: tvbSeries.id)
        guard let series = series, series.isInProduction ?? true else { return }

        tvbSeries.update(tvShow: series)
        for season in series.seasons ?? [] {
            let season = try? await TVStore.shared.season(
                season.seasonNumber,
                forTVSeries: series.id
            )
            guard let season = season else { continue }

            season.episodes?.forEach({ episode in
                if !tvbSeries.episodes.contains(where: {
                    $0.seasonNumber == episode.seasonNumber
                        && $0.episodeNumber == episode.episodeNumber
                }) {

                    tvbSeries.episodes.append(TVBuddyTVEpisode(episode: episode))
                    tvbSeries.checkWatching()
                }
            })
        }
    }
}
