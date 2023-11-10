//
//  TVStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class TVStore: ObservableObject {
    
    private let fetchSeriesQueue          = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchSeriesQueueTVStore")
    private let fetchSeasonQueue          = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchSeasonQueueTVStore")
    private let fetchPosterQueue          = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchPosterQueueTVStore")
    private let fetchBackdropQueue        = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchBackdropQueueTVStore")
    private let fetchBackdropTextQueue    = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchBackdropTextQueueTVStore")
    private let fetchCreditsQueue         = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchCreditsQueueTVStore")
    private let fetchRecommendationsQueue = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchRecommendationsQueueTVStore")
    private let fetchTrendingQueue        = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchTrendingQueueTVStore")
    private let fetchDiscoverQueue        = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchDiscoverQueueTVStore")

    private var pendingFetchSeriesTasks: [TMDb.TVShow.ID: Task<(), Never>]          = [:]
    private var pendingFetchSeasonTasks: [TMDb.TVShow.ID: Task<(), Never>]          = [:]
    private var pendingFetchPosterTasks: [TMDb.TVShow.ID: Task<(), Never>]          = [:]
    private var pendingFetchBackdropTasks: [TMDb.TVShow.ID: Task<(), Never>]        = [:]
    private var pendingFetchBackdropTextTasks: [TMDb.TVShow.ID: Task<(), Never>]    = [:]
    private var pendingFetchCreditsTasks: [TMDb.TVShow.ID: Task<(), Never>]         = [:]
    private var pendingFetchRecommendationsTasks: [TMDb.TVShow.ID: Task<(), Never>] = [:]
    private var pendingFetchTrendingTask: [Int: Task<(), Never>]                    = [:]
    private var pendingFetchDiscoverTask: [Int: Task<(), Never>]                    = [:]
	
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
	func show(withID id: TMDb.TVShow.ID) -> TMDb.TVShow? {
        if let show = shows[id] {
            return show
        }
        
        if pendingFetchSeriesTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let show = await tvManager.fetchShow(withID: id)
            if let show = show {
                shows[id] = show
            }
            
            fetchSeriesQueue.sync {
                pendingFetchSeriesTasks[id] = nil
            }
        }

        fetchSeriesQueue.sync {
            pendingFetchSeriesTasks[id] = fetchTask
        }

        return nil
	}
	
    @MainActor
	func season(_ season: Int, forTVShow id: TMDb.TVShow.ID) -> TMDb.TVShowSeason? {
        if let season = seasons[id]?[season] {
            return season
        }
        
        if pendingFetchSeasonTasks[id * 100 + season] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let result = await tvManager.fetchSeason(season, forTVShow: id)
            if let result = result {
                var tmpSeasons = seasons[id] ?? [:]
                tmpSeasons[season] = result
                self.seasons[id] = tmpSeasons
            }
            
            fetchSeasonQueue.sync {
                pendingFetchSeasonTasks[id * 100 + season] = nil
            }
        }

        fetchSeasonQueue.sync {
            pendingFetchSeasonTasks[id * 100 + season] = fetchTask
        }

        return nil
	}
	
    @MainActor
    func episode(_ episode: Int, season: Int, forTVShow id: TMDb.TVShow.ID) -> TMDb.TVShowEpisode? {
        return self.season(season, forTVShow: id)?.episodes?.first(where: { tvEpisode in
            tvEpisode.episodeNumber == episode
        })
    }
    
    @MainActor
	func poster(withID id: TMDb.TVShow.ID) -> URL? {
        if let url = posters[id] {
            return url
        }
        
        if pendingFetchPosterTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let url = await tvManager.fetchPoster(withID: id)
            if let url = url {
                posters[id] = url
            }
            
            fetchPosterQueue.sync {
                pendingFetchPosterTasks[id] = nil
            }
        }

        fetchPosterQueue.sync {
            pendingFetchPosterTasks[id] = fetchTask
        }

        return nil
	}
    
    @MainActor
	func backdrop(withID id: TMDb.TVShow.ID) -> URL? {
        if let url = backdrops[id] {
            return url
        }
        
        if pendingFetchBackdropTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let url = await tvManager.fetchBackdrop(withID: id)
            if let url = url {
                backdrops[id] = url
            }
            
            fetchBackdropQueue.sync {
                pendingFetchBackdropTasks[id] = nil
            }
        }

        fetchBackdropQueue.sync {
            pendingFetchBackdropTasks[id] = fetchTask
        }

        return nil
	}
    
    @MainActor
    func backdropWithText(withID id: TMDb.TVShow.ID) -> URL? {
        if let url = backdropsWithText[id] {
            return url
        }
        
        if pendingFetchBackdropTextTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let url = await tvManager.fetchBackdropWithText(withID: id)
            if let url = url {
                backdropsWithText[id] = url
            }
            
            fetchBackdropTextQueue.sync {
                pendingFetchBackdropTextTasks[id] = nil
            }
        }

        fetchBackdropTextQueue.sync {
            pendingFetchBackdropTextTasks[id] = fetchTask
        }

        return nil
    }
		
    @MainActor
	func credits(forTVShow id: TMDb.TVShow.ID) -> ShowCredits? {
        if let credits = self.credits[id] {
            return credits
        }
        
        if pendingFetchCreditsTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let credits = await tvManager.fetchCredits(forTVShow: id)
            if let credits = credits {
                self.credits[id] = credits
            }
            
            fetchCreditsQueue.sync {
                pendingFetchCreditsTasks[id] = nil
            }
        }

        fetchCreditsQueue.sync {
            pendingFetchCreditsTasks[id] = fetchTask
        }

        return nil
	}
	
    @MainActor
    func recommendations(forTVShow id: TMDb.TVShow.ID) -> [TMDb.TVShow]? {
        if let shows = recommendationsIDs[id] {
            return shows.compactMap { self.shows[$0] }
        }
        
        if pendingFetchRecommendationsTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let shows = await tvManager.fetchRecommendations(forTVShow: id)?.prefix(10)
            if let shows = shows {
                shows.forEach { show in
                    _ = self.show(withID: show.id)
                }
                
                recommendationsIDs[id] = shows.compactMap { $0.id }
            }
            
            fetchRecommendationsQueue.sync {
                pendingFetchRecommendationsTasks[id] = nil
            }
        }

        fetchRecommendationsQueue.sync {
            pendingFetchRecommendationsTasks[id] = fetchTask
        }

        return nil
    }
    
    @MainActor
    func trending() -> [TMDb.TVShow] {
        if trendingPage == 1 {
            return trendingIDs.compactMap { shows[$0] }
        }
        
        trendingPage = 1
        
        if pendingFetchTrendingTask[trendingPage] != nil {
            return trendingIDs.compactMap { shows[$0] }
        }
        
        let fetchTask = Task {
            let newPage = await tvManager.fetchTrending(page: trendingPage)
            
            newPage?.forEach { show in
                _ = self.show(withID: show.id)
                if !trendingIDs.contains(show.id) { trendingIDs.append(show.id) }
            }
        
            fetchTrendingQueue.sync {
                pendingFetchRecommendationsTasks[trendingPage] = nil
            }
        }
        
        fetchTrendingQueue.sync {
            pendingFetchTrendingTask[trendingPage] = fetchTask
        }
        
        return trendingIDs.compactMap { shows[$0] }
    }
    
    @MainActor
    func discover() -> [TMDb.TVShow] {
        if discoverPage == 1 {
            return discoverIDs.compactMap { shows[$0] }
        }
        
        discoverPage = 1
        
        if pendingFetchDiscoverTask[discoverPage] != nil {
            return discoverIDs.compactMap { shows[$0] }
        }
        
        let fetchTask = Task {
            let newPage = await tvManager.fetchDiscover(page: trendingPage)
            
            newPage?.forEach { show in
                _ = self.show(withID: show.id)
                if !discoverIDs.contains(show.id) { discoverIDs.append(show.id) }
            }
        
            fetchDiscoverQueue.sync {
                pendingFetchDiscoverTask[discoverPage] = nil
            }
        }
        
        fetchDiscoverQueue.sync {
            pendingFetchDiscoverTask[discoverPage] = fetchTask
        }
        
        return discoverIDs.compactMap { shows[$0] }
    }
}

extension TVStore {
	
//	@MainActor
//	func fetchRecommendations(forTVShow id: TMDb.TVShow.ID) {
//		guard recommendations(forTVShow: id) == nil else {
//			return
//		}
//		
//		Task {
//			let shows = await tvManager.fetchRecommendations(forTVShow: id)
//			
//			guard let shows = shows else {
//				return
//			}
//			
//			shows.forEach {
//				if self.shows[$0.id] == nil {
//					self.shows[$0.id] = $0
//				}
//			}
//			
//			recommendationsIDs[id] = shows.compactMap { $0.id }
//		}
//	}
//	
//	@MainActor
//	func fetchDiscover() {
//		discoverPage += 1
//		
//		Task {
//			let newPage = await tvManager.fetchDiscover(page: discoverPage)
//			
//			newPage?.forEach { show in
//				if shows[show.id] == nil {
//					shows[show.id] = show
//				}
//				
//				if !discoverIDs.contains(show.id) {
//					discoverIDs.append(show.id)
//				}
//			}
//		}
//	}
//	
//	@MainActor
//	func fetchNextDiscover(currentTVShow: TMDb.TVShow, offset: Int = AppConstants.nextPageOffset) {
//		let index = discoverIDs.firstIndex(where: { $0 == currentTVShow.id })
//		let thresholdIndex = discoverIDs.endIndex - offset
//		guard index == thresholdIndex else {
//			return
//		}
//
//		fetchDiscover()
//	}
//	
//	@MainActor
//	func fetchTrending() {
//		trendingPage += 1
//		
//		Task {
//			let newPage = await tvManager.fetchTrending(page: trendingPage)
//			
//			newPage?.forEach { show in
//				if shows[show.id] == nil {
//					shows[show.id] = show
//				}
//				
//				if !trendingIDs.contains(show.id) {
//					trendingIDs.append(show.id)
//				}
//			}
//		}
//	}
//	
//	@MainActor
//	func fetchNextTrending(currentTVShow: TMDb.TVShow, offset: Int = AppConstants.nextPageOffset) {
//		let index = trendingIDs.firstIndex(where: { $0 == currentTVShow.id })
//		let thresholdIndex = trendingIDs.endIndex - offset
//		guard index == thresholdIndex else {
//			return
//		}
//
//		fetchTrending()
//	}
	
}
