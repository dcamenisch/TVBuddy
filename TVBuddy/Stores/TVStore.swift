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

    @Published var shows: [TMDb.TVShow.ID: TMDb.TVShow] = [:]
    @Published var seasons: [TMDb.TVShow.ID: [Int: TMDb.TVShowSeason]] = [:]
    @Published var posters: [TMDb.TVShow.ID: URL] = [:]
    @Published var backdrops: [TMDb.TVShow.ID: URL] = [:]
    @Published var backdropsWithText: [TMDb.TVShow.ID: URL] = [:]
    @Published var credits: [TMDb.TVShow.ID: TMDb.ShowCredits] = [:]
    @Published var recommendationsIDs: [TMDb.TVShow.ID: [TMDb.TVShow.ID]] = [:]
    @Published var discoverIDs: [TMDb.TVShow.ID] = []
    @Published var trendingIDs: [TMDb.TVShow.ID] = []

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    init(tvManager: TVManager = TVManager()) {
        self.tvManager = tvManager
    }
    
    @MainActor
    func show(withID id: TMDb.TVShow.ID) async -> TMDb.TVShow? {
        if self.shows[id] == nil {
            let show = await tvManager.fetchShow(withID: id)
            guard let show = show else { return nil }
            
            self.shows[id] = show
        }
        
        return self.shows[id]
    }
    
    @MainActor
    func season(_ season: Int, forTVShow id: TMDb.TVShow.ID) async -> TMDb.TVShowSeason? {
        if self.seasons[id]?[season] == nil {
            let result = await tvManager.fetchSeason(season, forTVShow: id)
            guard let result = result else { return nil }
            
            var tmpSeasons = self.seasons[id] ?? [:]
            tmpSeasons[season] = result
            self.seasons[id] = tmpSeasons
        }
        
        return self.seasons[id]?[season]
    }
    
    @MainActor
    func episode(_ episode: Int, season: Int, forTVShow id: TMDb.TVShow.ID) async -> TMDb.TVShowEpisode? {
        return await self.season(season, forTVShow: id)?.episodes?.first(where: { tvEpisode in
            tvEpisode.episodeNumber == episode
        })
    }

    @MainActor
    func poster(withID id: TMDb.TVShow.ID) async -> URL? {
        if self.posters[id] == nil {
            let url = await tvManager.fetchPoster(withID: id)
            guard let url = url else { return nil }
            
            self.posters[id] = url
        }
        
        return self.posters[id]
    }
    
    @MainActor
    func backdrop(withID id: TMDb.TVShow.ID) async -> URL? {
        if self.backdrops[id] == nil {
            let url = await tvManager.fetchBackdrop(withID: id)
            guard let url = url else { return nil }
            
            self.backdrops[id] = url
        }
        
        return self.backdrops[id]
    }
    
    @MainActor
    func backdropWithText(withID id: TMDb.TVShow.ID) async -> URL? {
        if self.backdropsWithText[id] == nil {
            let url = await tvManager.fetchBackdropWithText(withID: id)
            guard let url = url else { return nil }
            
            self.backdropsWithText[id] = url
        }
        
        return self.backdropsWithText[id]
    }

    @MainActor
    func credits(forTVShow id: TMDb.TVShow.ID) async -> TMDb.ShowCredits? {
        if self.credits[id] == nil {
            let credits = await tvManager.fetchCredits(forTVShow: id)
            guard let credits = credits else { return nil }
            
            self.credits[id] = credits
        }
        
        return self.credits[id]
    }
    
    @MainActor
    func recommendations(forTVShow id: TMDb.TVShow.ID) async -> [TMDb.TVShow]? {
        if self.recommendationsIDs[id] == nil {
            let shows = await tvManager.fetchRecommendations(forTVShow: id)
            guard let shows = shows else { return nil }
            
            await withTaskGroup(of: Void.self) { taskGroup in
                for show in shows {
                    taskGroup.addTask {
                        _ = await self.show(withID: show.id)
                    }
                }
            }
            
            self.recommendationsIDs[id] = shows.compactMap { $0.id }
        }
        
        return self.recommendationsIDs[id]!.compactMap { self.shows[$0] }
    }
    
    @MainActor
    func trending() async -> [TMDb.TVShow] {
        if trendingPage == 1 {
            return trendingIDs.compactMap { shows[$0] }
        }
        
        trendingPage = 1
                
        let page = await tvManager.fetchTrending(page: trendingPage)
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
        
        return trendingIDs.compactMap { shows[$0] }
    }
    
    @MainActor
    func discover() async -> [TMDb.TVShow] {
        if discoverPage == 1 {
            return discoverIDs.compactMap { shows[$0] }
        }
        
        discoverPage = 1
                
        let page = await tvManager.fetchDiscover(page: trendingPage)
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
        
        return discoverIDs.compactMap { shows[$0] }
    }
}

extension TVStore {

    //    @MainActor
    //    func fetchRecommendations(forTVShow id: TMDb.TVShow.ID) {
    //        guard recommendations(forTVShow: id) == nil else {
    //            return
    //        }
    //
    //        Task {
    //            let shows = await tvManager.fetchRecommendations(forTVShow: id)
    //
    //            guard let shows = shows else {
    //                return
    //            }
    //
    //            shows.forEach {
    //                if self.shows[$0.id] == nil {
    //                    self.shows[$0.id] = $0
    //                }
    //            }
    //
    //            recommendationsIDs[id] = shows.compactMap { $0.id }
    //        }
    //    }
    //
    //    @MainActor
    //    func fetchDiscover() {
    //        discoverPage += 1
    //
    //        Task {
    //            let newPage = await tvManager.fetchDiscover(page: discoverPage)
    //
    //            newPage?.forEach { show in
    //                if shows[show.id] == nil {
    //                    shows[show.id] = show
    //                }
    //
    //                if !discoverIDs.contains(show.id) {
    //                    discoverIDs.append(show.id)
    //                }
    //            }
    //        }
    //    }
    //
    //    @MainActor
    //    func fetchNextDiscover(currentTVShow: TMDb.TVShow, offset: Int = AppConstants.nextPageOffset) {
    //        let index = discoverIDs.firstIndex(where: { $0 == currentTVShow.id })
    //        let thresholdIndex = discoverIDs.endIndex - offset
    //        guard index == thresholdIndex else {
    //            return
    //        }
    //
    //        fetchDiscover()
    //    }
    //
    //    @MainActor
    //    func fetchTrending() {
    //        trendingPage += 1
    //
    //        Task {
    //            let newPage = await tvManager.fetchTrending(page: trendingPage)
    //
    //            newPage?.forEach { show in
    //                if shows[show.id] == nil {
    //                    shows[show.id] = show
    //                }
    //
    //                if !trendingIDs.contains(show.id) {
    //                    trendingIDs.append(show.id)
    //                }
    //            }
    //        }
    //    }
    //
    //    @MainActor
    //    func fetchNextTrending(currentTVShow: TMDb.TVShow, offset: Int = AppConstants.nextPageOffset) {
    //        let index = trendingIDs.firstIndex(where: { $0 == currentTVShow.id })
    //        let thresholdIndex = trendingIDs.endIndex - offset
    //        guard index == thresholdIndex else {
    //            return
    //        }
    //
    //        fetchTrending()
    //    }

}
