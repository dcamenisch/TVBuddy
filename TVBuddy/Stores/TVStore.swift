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
	func show(withID id: TMDb.TVShow.ID) -> TMDb.TVShow? {
        if shows[id] == nil {
            Task {
                let show = await tvManager.fetchShow(withID: id)
                guard let show = show else { return }
                shows[id] = show
                                
                show.seasons?.forEach { season in
                    _ = self.season(season.seasonNumber, forTVShow: id)
                }
            }
        }
        
		return shows[id]
	}
	
    @MainActor
	func season(_ season: Int, forTVShow id: TMDb.TVShow.ID) -> TMDb.TVShowSeason? {
        if seasons[id]?[season] == nil {
            Task {
                let result = await tvManager.fetchSeason(season, forTVShow: id)
                guard let result = result else { return }
                
                var tmpSeasons = seasons[id] ?? [:]
                tmpSeasons[season] = result
                self.seasons[id] = tmpSeasons
            }
        }
                
        return seasons[id]?[season]
	}
	
    @MainActor
    func episode(_ episode: Int, season: Int, forTVShow id: TMDb.TVShow.ID) -> TMDb.TVShowEpisode? {
        
        return self.season(season, forTVShow: id)?.episodes?[episode - 1]
    }
    
    @MainActor
	func poster(withID id: TMDb.TVShow.ID) -> URL? {
        if posters[id] == nil {
            Task {
                let url = await tvManager.fetchPoster(withID: id)
                guard let url = url else { return }
                posters[id] = url
            }
        }
        
		return posters[id]
	}
    
    @MainActor
	func backdrop(withID id: TMDb.TVShow.ID) -> URL? {
        if backdrops[id] == nil {
            Task {
                let url = await tvManager.fetchBackdrop(withID: id)
                guard let url = url else { return }
                backdrops[id] = url
            }
        }
        
		return backdrops[id]
	}
    
    @MainActor
    func backdropWithText(withID id: TMDb.TVShow.ID) -> URL? {
        if backdropsWithText[id] == nil {
            Task {
                let url = await tvManager.fetchBackdropWithText(withID: id)
                guard let url = url else { return }
                backdropsWithText[id] = url
            }
        }
        
        return backdropsWithText[id]
    }
		
    @MainActor
	func credits(forTVShow id: TMDb.TVShow.ID) -> ShowCredits? {
        if credits[id] == nil {
            Task {
                let credits = await tvManager.fetchCredits(forTVShow: id)
                guard let credits = credits else { return }
                self.credits[id] = credits
            }
        }
        
        return credits[id]
	}
	
    @MainActor
    func recommendations(forTVShow id: TMDb.TVShow.ID) -> [TMDb.TVShow]? {
        if recommendationsIDs[id] == nil {
            Task {
                let shows = await self.tvManager.fetchRecommendations(forTVShow: id)
                guard let shows = shows else { return }
                
                shows.forEach { show in
                    _ = self.show(withID: show.id)
                }
                
                recommendationsIDs[id] = shows.compactMap { $0.id }
            }
        }
        
        return recommendationsIDs[id]?.compactMap { shows[$0] }
    }
    
    @MainActor
    func trending() -> [TMDb.TVShow] {
        if trendingIDs.isEmpty {
            trendingPage = 1
            
            Task {
                let newPage = await tvManager.fetchTrending(page: trendingPage)
                newPage?.forEach { show in
                    _ = self.show(withID: show.id)
                    if !trendingIDs.contains(show.id) { trendingIDs.append(show.id) }
                }
            }
        }
        
        return trendingIDs.compactMap { shows[$0] }
    }
    
    @MainActor
    func discover() -> [TMDb.TVShow] {
        if discoverIDs.isEmpty {
            discoverPage = 1
            
            Task {
                let newPage = await tvManager.fetchDiscover(page: discoverPage)
                newPage?.forEach { show in
                    _ = self.show(withID: show.id)
                    if !discoverIDs.contains(show.id) { discoverIDs.append(show.id) }
                }
            }
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
