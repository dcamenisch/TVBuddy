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

@ModelActor
actor TVShowActor {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TVShowActor.self)
    )
    
    func insertTVShow(id: TVSeries.ID, watched: Bool, isFavorite: Bool, episodeID: TVEpisode.ID = -1) async {
        let tvShow = await TVStore.shared.show(withID: id)
        
        guard let tvShow = tvShow else {
            return
        }
        
        let tvbTVShow = TVBuddyTVShow(tvShow: tvShow, startedWatching: watched, finishedWatching: watched, isFavorite: isFavorite)
        modelContext.insert(tvbTVShow)
        
        do {
            try modelContext.save()
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
        
        let episodes = await withTaskGroup(of: TVSeason?.self, returning: [TVEpisode].self) { group in
            for season in tvShow.seasons ?? [] {
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
            TVBuddyTVEpisode(episode: $0, watched: $0.id == episodeID ? true : $0.seasonNumber == 0 ? false : watched)
        }
        
        tvbTVShow.episodes.append(contentsOf: episodes)
        
        do {
            try modelContext.save()
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }
    
    func updateTVShows() async {
        do {
            let now = Date.now
            let past = Date.distantPast
            let future = Date.distantFuture
            
            let tvbTVShows = try modelContext.fetch(FetchDescriptor<TVBuddyTVShow>())
            for tvbTVShow in tvbTVShows {
                let tvShow = await TVStore.shared.show(withID: tvbTVShow.id)
                
                guard let tvShow = tvShow else {
                    continue
                }
                
                if tvbTVShow.lastAirDate ?? past < tvShow.lastAirDate ?? future {
                    tvbTVShow.update(tvShow: tvShow)
                    TVShowActor.logger.info("Updated tv show: \(tvShow.name)")
                    
                    for season in tvShow.seasons ?? [] {
                        let season = await TVStore.shared.season(season.seasonNumber, forTVSeries: tvShow.id)
                        
                        guard let season = season else {
                            continue
                        }
                        
                        for episode in season.episodes ?? [] {
                            if !tvbTVShow.episodes.contains(where: { $0.seasonNumber == episode.seasonNumber && $0.episodeNumber == episode.episodeNumber }) {
                                tvbTVShow.episodes.append(TVBuddyTVEpisode(episode: episode))
                                tvbTVShow.checkWatching()
                                TVShowActor.logger.info("Added new episodes for tv show: \(tvShow.name)")
                            }
                        }
                    }
                }
            }
            
            let predicate = #Predicate<TVBuddyTVEpisode> {$0.airDate ?? future >= now}
            let tvbTVEpisodes = try modelContext.fetch(FetchDescriptor<TVBuddyTVEpisode>(predicate: predicate))
            for tvbTVEpisode in tvbTVEpisodes {
                let episode = await TVStore.shared.episode(tvbTVEpisode.episodeNumber, season: tvbTVEpisode.seasonNumber, forTVSeries: tvbTVEpisode.tvShow?.id ?? 0)
                
                guard let episode = episode else {
                    continue
                }
                
                tvbTVEpisode.update(episode: episode)
                TVShowActor.logger.info("Updated episodes: \(episode.name)")
            }
            
            try modelContext.save()
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "LastMediaUpdate")
        } catch {
            TVShowActor.logger.error("\(error.localizedDescription)")
        }
    }
}
