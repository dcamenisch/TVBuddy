//
//  TVStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class TVStore: ObservableObject {
    private let tvManager: TVManager

    @Published var shows: [TVSeries.ID: TVSeries] = [:]
    @Published var seasons: [TVSeries.ID: [Int: TVSeason]] = [:]
    @Published var posters: [[Int?]: URL] = [:]
    @Published var backdrops: [[Int?]: URL] = [:]
    @Published var backdropsWithText: [TVSeries.ID: URL] = [:]
    @Published var credits: [TVSeries.ID: ShowCredits] = [:]
    @Published var recommendationsIDs: [TVSeries.ID: [TVSeries.ID]] = [:]
    @Published var similarIDs: [TVSeries.ID: [TVSeries.ID]] = [:]
    @Published var discoverIDs: [TVSeries.ID] = []
    @Published var trendingIDs: [TVSeries.ID] = []

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    init(tvManager: TVManager = TVManager()) {
        self.tvManager = tvManager
    }

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
    func poster(withID id: TVSeries.ID, season: Int? = nil) async -> URL? {
        if posters[[id, season]] == nil {
            let url = await tvManager.fetchPoster(id: id, season: season)
            guard let url = url else { return nil }

            posters[[id, season]] = url
        }

        return posters[[id, season]]
    }

    @MainActor
    func backdrop(withID id: TVSeries.ID, season: Int? = nil, episode: Int? = nil) async -> URL? {
        if backdrops[[id, season, episode]] == nil {
            let url = await tvManager.fetchBackdrop(id: id, season: season, episode: episode)
            guard let url = url else { return nil }

            backdrops[[id, season, episode]] = url
        }

        return backdrops[[id, season, episode]]
    }

    @MainActor
    func backdropWithText(withID id: TVSeries.ID) async -> URL? {
        if backdropsWithText[id] == nil {
            let url = await tvManager.fetchBackdropWithText(id: id)
            guard let url = url else { return nil }

            backdropsWithText[id] = url
        }

        return backdropsWithText[id]
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
