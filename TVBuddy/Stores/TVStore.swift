//
//  TVStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class TVStore: ObservableObject {
    static let shared = TVStore()
    
    private let tvManager: TVManager = TVManager()
    
    private var imageService: ImagesConfiguration? {
            AppConstants.apiConfiguration?.images
        }

    private var shows: [TVSeries.ID: TVSeries] = [:]
    private var seasons: [TVSeries.ID: [Int: TVSeason]] = [:]
    private var seriesImages: [TVSeries.ID: ImageCollection] = [:]
    private var seasonImages: [[Int?]: TVSeasonImageCollection] = [:]
    private var episodeImages: [[Int?]: TVEpisodeImageCollection] = [:]
    private var credits: [TVSeries.ID: ShowCredits] = [:]
    private var aggregateCredits: [TVSeries.ID: TVSeriesAggregateCredits] = [:]
    private var recommendationsIDs: [TVSeries.ID: [TVSeries.ID]] = [:]
    private var similarIDs: [TVSeries.ID: [TVSeries.ID]] = [:]
    private var discoverIDs: [TVSeries.ID] = []
    private var trendingIDs: [TVSeries.ID] = []

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    @MainActor
    func show(withID id: TVSeries.ID) async -> TVSeries? {
        if shows[id] == nil {
            let show = await tvManager.fetchShow(id: id)
            guard let show = show else { return nil }

            shows[id] = show
        }

        return shows[id]
    }

    @MainActor
    func season(_ season: Int, forTVSeries id: TVSeries.ID) async -> TVSeason? {
        if seasons[id]?[season] == nil {
            let result = await tvManager.fetchSeason(season: season, id: id)
            guard let result = result else { return nil }

            var tmpSeasons = seasons[id] ?? [:]
            tmpSeasons[season] = result
            seasons[id] = tmpSeasons
        }

        return seasons[id]?[season]
    }

    @MainActor
    func episode(_ episode: Int, season: Int, forTVSeries id: TVSeries.ID) async -> TVEpisode? {
        return await self.season(season, forTVSeries: id)?.episodes?.first(where: { tvEpisode in
            tvEpisode.episodeNumber == episode
        })
    }
    
    @MainActor
    func seriesImages(id: TVSeries.ID) async -> ImageCollection? {
        if seriesImages[id] == nil {
            let imageCollection = await tvManager.fetchImages(id: id)
            guard let imageCollection = imageCollection else { return nil }

            seriesImages[id] = imageCollection
        }
        
        return seriesImages[id]
    }
    
    @MainActor
    func seasonImages(season: Int, id: TVSeries.ID) async -> TVSeasonImageCollection? {
        if seasonImages[[id, season]] == nil {
            let imageCollection = await tvManager.fetchImages(season: season, id: id)
            guard let imageCollection = imageCollection else { return nil }

            seasonImages[[id, season]] = imageCollection
        }
        
        return seasonImages[[id, season]]
    }
    
    @MainActor
    func episodeImages(episode: Int, season: Int, id: TVSeries.ID) async -> TVEpisodeImageCollection? {
        if episodeImages[[id, season, episode]] == nil {
            let imageCollection = await tvManager.fetchImages(episode: episode, season: season, id: id)
            guard let imageCollection = imageCollection else { return nil }

            episodeImages[[id, season, episode]] = imageCollection
        }
        
        return episodeImages[[id, season, episode]]
    }
    
    @MainActor
    func posters(id: TVSeries.ID, season: Int? = nil) async -> [URL] {
        if let season = season, let images = await seasonImages(season: season, id: id) {
            var posters = images.posters.filter { $0.languageCode != nil }
            posters = posters.isEmpty ? images.posters : posters
            
            return posters.compactMap { poster in
                imageService?.posterURL(
                    for: poster.filePath,
                    idealWidth: AppConstants.idealPosterWidth
                )
            }
        }
        
        guard let images = await seriesImages(id: id) else { return [] }
        
        var posters = images.posters.filter { $0.languageCode != nil }
        posters = posters.isEmpty ? images.posters : posters
        
        return posters.compactMap { poster in
            imageService?.posterURL(
                for: poster.filePath,
                idealWidth: AppConstants.idealPosterWidth
            )
        }
    }

    @MainActor
    func backdrops(id: TVSeries.ID) async -> [URL] {
        guard let images = await seriesImages(id: id) else { return [] }
        let backdrops = images.backdrops.filter { $0.languageCode == nil }
        
        return backdrops.compactMap { backdrop in
            imageService?.backdropURL(
                for: backdrop.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        }
    }

    @MainActor
    func backdropsWithText(id: TVSeries.ID) async -> [URL] {
        guard let images = await seriesImages(id: id) else { return [] }
        
        var backdrops = images.backdrops.filter { $0.languageCode != nil }
        backdrops = backdrops.isEmpty ? images.backdrops : backdrops
    
        return backdrops.compactMap { backdrop in
            imageService?.backdropURL(
                for: backdrop.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        }
    }
    
    @MainActor
    func stills(episode: Int, season: Int, id: TVSeries.ID)async -> [URL] {
        guard let images = await episodeImages(episode: episode, season: season, id: id) else {
            return []
        }
        
        return images.stills.compactMap { still in
            imageService?.backdropURL(
                for: still.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        }
    }

    @MainActor
    func credits(forTVSeries id: TVSeries.ID) async -> ShowCredits? {
        if credits[id] == nil {
            let credits = await tvManager.fetchCredits(id: id)
            guard let credits = credits else { return nil }

            self.credits[id] = credits
        }

        return credits[id]
    }
    
    @MainActor
    func aggregateCredits(forTVSeries id: TVSeries.ID) async -> TVSeriesAggregateCredits? {
        if aggregateCredits[id] == nil {
            let aggregateCredits = await tvManager.fetchAggregateCredits(id: id)
            guard let aggregateCredits = aggregateCredits else { return nil }

            self.aggregateCredits[id] = aggregateCredits
        }

        return aggregateCredits[id]
    }

    @MainActor
    func recommendations(forTVSeries id: TVSeries.ID) async -> [TVSeries]? {
        if recommendationsIDs[id] == nil {
            let shows = await tvManager.fetchRecommendations(id: id)
            guard let shows = shows else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for show in shows {
                    taskGroup.addTask {
                        _ = await self.show(withID: show.id)
                    }
                }
            }

            recommendationsIDs[id] = shows.compactMap { $0.id }
        }

        return recommendationsIDs[id]!.compactMap { self.shows[$0] }
    }

    @MainActor
    func similar(toTVSeries id: TVSeries.ID) async -> [TVSeries]? {
        if similarIDs[id] == nil {
            let shows = await tvManager.fetchSimilar(id: id)
            guard let shows = shows else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for show in shows {
                    taskGroup.addTask {
                        _ = await self.show(withID: show.id)
                    }
                }
            }

            similarIDs[id] = shows.compactMap { $0.id }
        }

        return similarIDs[id]!.compactMap { self.shows[$0] }
    }

    @MainActor
    func trending(newPage: Bool = false) async -> [TVSeries] {
        if !newPage && trendingPage != 0 {
            return trendingIDs.compactMap { shows[$0] }
        }

        let nextPageNumber = trendingPage + 1

        let page = await tvManager.fetchTrending(page: nextPageNumber)
        guard let page = page else { return [] }

        await withTaskGroup(of: Void.self) { taskGroup in
            for show in page {
                taskGroup.addTask {
                    _ = await self.show(withID: show.id)
                }
            }
        }

        page.forEach { show in
            if !self.trendingIDs.contains(show.id) { self.trendingIDs.append(show.id) }
        }

        trendingPage = max(nextPageNumber, trendingPage)
        return trendingIDs.compactMap { shows[$0] }
    }

    @MainActor
    func discover(newPage: Bool = false) async -> [TVSeries] {
        if !newPage && discoverPage != 0 {
            return discoverIDs.compactMap { shows[$0] }
        }

        let nextPageNumber = discoverPage + 1

        let page = await tvManager.fetchDiscover(page: nextPageNumber)
        guard let page = page else { return [] }

        await withTaskGroup(of: Void.self) { taskGroup in
            for show in page {
                taskGroup.addTask {
                    _ = await self.show(withID: show.id)
                }
            }
        }

        page.forEach { show in
            if !self.discoverIDs.contains(show.id) { self.discoverIDs.append(show.id) }
        }

        discoverPage = max(nextPageNumber, discoverPage)
        return discoverIDs.compactMap { shows[$0] }
    }
}
