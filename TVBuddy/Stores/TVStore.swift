//
//  TVStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class TVStore: ObservableObject {
    private let showCache = CacheService<TVSeries.ID, TVSeries>()
    private let seasonCache = CacheService<TVSeasonCacheKey, TVSeason>()
    private let seriesImageCache = CacheService<TVSeries.ID, ImageCollection>()
    private let seasonImageCache = CacheService<TVSeasonImageCacheKey, TVSeasonImageCollection>()
    private let episodeImageCache = CacheService<TVEpisodeImageCacheKey, TVEpisodeImageCollection>()
    private let creditCache = CacheService<TVSeries.ID, ShowCredits>()
    private let aggregateCreditCache = CacheService<TVSeries.ID, TVSeriesAggregateCredits>()
    private let recommendationsCache = CacheService<TVSeries.ID, [TVSeries.ID]>()
    private let similarShowsCache = CacheService<TVSeries.ID, [TVSeries.ID]>()
    private let discoverShowsCache = CacheService<String, [TVSeries.ID]>()
    private let trendingShowsCache = CacheService<String, [TVSeries.ID]>()

    static let shared = TVStore()

    private let tvManager: TVManager = TVManager()

    private var imageService: ImagesConfiguration? { AppConstants.apiConfiguration?.images }

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    @MainActor
    func show(withID id: TVSeries.ID) async throws -> TVSeries? {
        if let cachedShow = showCache.object(forKey: id) {
            return cachedShow
        }

        let show = try await tvManager.fetchShow(id: id)
        guard let show = show else { return nil }

        showCache.setObject(show, forKey: id)
        return show
    }

    @MainActor
    func season(_ seasonNumber: Int, forTVSeries id: TVSeries.ID) async throws -> TVSeason? {
        let cacheKey = TVSeasonCacheKey(seriesID: id, seasonNumber: seasonNumber)
        if let cachedSeason = seasonCache.object(forKey: cacheKey) {
            return cachedSeason
        }

        let result = try await tvManager.fetchSeason(season: seasonNumber, id: id)
        guard let result = result else { return nil }

        seasonCache.setObject(result, forKey: cacheKey)
        return result
    }

    @MainActor
    func episode(_ episode: Int, season: Int, forTVSeries id: TVSeries.ID) async throws
        -> TVEpisode?
    {
        let season = try await self.season(season, forTVSeries: id)
        return season?.episodes?.first(where: { tvEpisode in
            tvEpisode.episodeNumber == episode
        })
    }

    @MainActor
    func seriesImages(id: TVSeries.ID) async -> ImageCollection? {
        if let cachedImages = seriesImageCache.object(forKey: id) {
            return cachedImages
        }

        let imageCollection = await tvManager.fetchImages(id: id)
        guard let imageCollection = imageCollection else { return nil }

        seriesImageCache.setObject(imageCollection, forKey: id)
        return imageCollection
    }

    @MainActor
    func seasonImages(season: Int, id: TVSeries.ID) async -> TVSeasonImageCollection? {
        let cacheKey = TVSeasonImageCacheKey(seriesID: id, seasonNumber: season)
        if let cachedImages = seasonImageCache.object(forKey: cacheKey) {
            return cachedImages
        }

        let imageCollection = await tvManager.fetchImages(season: season, id: id)
        guard let imageCollection = imageCollection else { return nil }

        seasonImageCache.setObject(imageCollection, forKey: cacheKey)
        return imageCollection
    }

    @MainActor
    func episodeImages(episode: Int, season: Int, id: TVSeries.ID) async
        -> TVEpisodeImageCollection?
    {
        let cacheKey = TVEpisodeImageCacheKey(
            seriesID: id,
            seasonNumber: season,
            episodeNumber: episode
        )
        if let cachedImages = episodeImageCache.object(forKey: cacheKey) {
            return cachedImages
        }

        let imageCollection = await tvManager.fetchImages(episode: episode, season: season, id: id)
        guard let imageCollection = imageCollection else { return nil }

        episodeImageCache.setObject(imageCollection, forKey: cacheKey)
        return imageCollection
    }

    @MainActor
    func logos(id: TVSeries.ID) async -> [URL] {
        guard let images = await seriesImages(id: id) else { return [] }

        return images.logos.compactMap { logo in
            imageService?.logoURL(
                for: logo.filePath
            )
        }
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
    func stills(episode: Int, season: Int, id: TVSeries.ID) async -> [URL] {
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
        if let cachedCredits = creditCache.object(forKey: id) {
            return cachedCredits
        }

        let fetchedCredits = await tvManager.fetchCredits(id: id)
        guard let fetchedCredits = fetchedCredits else { return nil }

        creditCache.setObject(fetchedCredits, forKey: id)
        return fetchedCredits
    }

    @MainActor
    func aggregateCredits(forTVSeries id: TVSeries.ID) async -> TVSeriesAggregateCredits? {
        if let cachedCredits = aggregateCreditCache.object(forKey: id) {
            return cachedCredits
        }

        let fetchedCredits = await tvManager.fetchAggregateCredits(id: id)
        guard let fetchedCredits = fetchedCredits else { return nil }

        aggregateCreditCache.setObject(fetchedCredits, forKey: id)
        return fetchedCredits
    }

    @MainActor
    func recommendations(forTVSeries id: TVSeries.ID) async -> [TVSeries]? {
        var showIDs: [TVSeries.ID]? = recommendationsCache.object(forKey: id)

        if showIDs == nil {
            let fetchedShows = await tvManager.fetchRecommendations(id: id)
            guard let fetchedShows = fetchedShows else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for show in fetchedShows {
                    taskGroup.addTask {
                        _ = try? await self.show(withID: show.id)  // Populates showCache
                    }
                }
            }
            let ids = fetchedShows.map { $0.id }
            recommendationsCache.setObject(ids, forKey: id)
            showIDs = ids
        }

        guard let finalShowIDs = showIDs else { return [] }

        var resultShows: [TVSeries] = []
        for showID in finalShowIDs {
            if let show = try? await self.show(withID: showID) {
                resultShows.append(show)
            }
        }
        return resultShows
    }

    @MainActor
    func similar(toTVSeries id: TVSeries.ID) async -> [TVSeries]? {
        var showIDs: [TVSeries.ID]? = similarShowsCache.object(forKey: id)

        if showIDs == nil {
            let fetchedShows = await tvManager.fetchSimilar(id: id)
            guard let fetchedShows = fetchedShows else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for show in fetchedShows {
                    taskGroup.addTask {
                        _ = try? await self.show(withID: show.id)  // Populates showCache
                    }
                }
            }
            let ids = fetchedShows.map { $0.id }
            similarShowsCache.setObject(ids, forKey: id)
            showIDs = ids
        }

        guard let finalShowIDs = showIDs else { return [] }

        var resultShows: [TVSeries] = []
        for showID in finalShowIDs {
            if let show = try? await self.show(withID: showID) {
                resultShows.append(show)
            }
        }
        return resultShows
    }

    @MainActor
    func trending(newPage: Bool = false) async -> [TVSeries] {
        let cacheKey = "trendingShows"
        var trendingIDs: [TVSeries.ID]? = trendingShowsCache.object(forKey: cacheKey)

        if newPage || trendingIDs == nil {
            if newPage && trendingIDs == nil {
                // No change to trendingPage if cache expired and new page requested
            } else if newPage {
                trendingPage += 1
            } else {
                trendingPage = 1
            }

            let pageItems = await tvManager.fetchTrending(page: trendingPage)
            guard let pageItems = pageItems else {
                if trendingIDs == nil { trendingShowsCache.removeObject(forKey: cacheKey) }
                return []
            }

            await withTaskGroup(of: Void.self) { taskGroup in
                for show in pageItems {
                    taskGroup.addTask {
                        _ = try? await self.show(withID: show.id)  // Populates showCache
                    }
                }
            }

            var currentTrendingIDs = newPage ? (trendingIDs ?? []) : []
            pageItems.forEach { show in
                if !currentTrendingIDs.contains(show.id) { currentTrendingIDs.append(show.id) }
            }
            trendingShowsCache.setObject(currentTrendingIDs, forKey: cacheKey)
            trendingIDs = currentTrendingIDs
        }

        guard let finalTrendingIDs = trendingIDs else { return [] }

        var resultShows: [TVSeries] = []
        for showID in finalTrendingIDs {
            if let show = try? await self.show(withID: showID) {
                resultShows.append(show)
            }
        }
        return resultShows
    }

    @MainActor
    func discover(newPage: Bool = false) async -> [TVSeries] {
        let cacheKey = "discoverShows"
        var discoverIDs: [TVSeries.ID]? = discoverShowsCache.object(forKey: cacheKey)

        if newPage || discoverIDs == nil {
            if newPage && discoverIDs == nil {
                // No change to discoverPage if cache expired and new page requested
            } else if newPage {
                discoverPage += 1
            } else {
                discoverPage = 1
            }

            let pageItems = await tvManager.fetchDiscover(page: discoverPage)
            guard let pageItems = pageItems else {
                if discoverIDs == nil { discoverShowsCache.removeObject(forKey: cacheKey) }
                return []
            }

            await withTaskGroup(of: Void.self) { taskGroup in
                for show in pageItems {
                    taskGroup.addTask {
                        _ = try? await self.show(withID: show.id)  // Populates showCache
                    }
                }
            }

            var currentDiscoverIDs = newPage ? (discoverIDs ?? []) : []
            pageItems.forEach { show in
                if !currentDiscoverIDs.contains(show.id) { currentDiscoverIDs.append(show.id) }
            }
            discoverShowsCache.setObject(currentDiscoverIDs, forKey: cacheKey)
            discoverIDs = currentDiscoverIDs
        }

        guard let finalDiscoverIDs = discoverIDs else { return [] }

        var resultShows: [TVSeries] = []
        for showID in finalDiscoverIDs {
            if let show = try? await self.show(withID: showID) {
                resultShows.append(show)
            }
        }
        return resultShows
    }
}

// MARK: - Cache Key Structures
struct TVSeasonCacheKey: Hashable {
    let seriesID: TVSeries.ID
    let seasonNumber: Int
}

struct TVSeasonImageCacheKey: Hashable {
    let seriesID: TVSeries.ID
    let seasonNumber: Int
}

struct TVEpisodeImageCacheKey: Hashable {
    let seriesID: TVSeries.ID
    let seasonNumber: Int
    let episodeNumber: Int
}
