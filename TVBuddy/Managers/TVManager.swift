//
//  TVManager.swift
//  tvTracker
//
//  Created by Danny on 07.07.22.
//

import Foundation
import TMDb

class TVManager {
	
	private let tmdb = AppConstants.tmdb
	
	func fetchShow(withID id: TMDb.TVShow.ID) async -> TMDb.TVShow? {
		do {
			return try await tmdb.tvShows.details(forTVShow: id)
		} catch {
			return nil
		}
	}
	
	func fetchSeason(_ season: Int, forTVShow id: TMDb.TVShow.ID) async -> TMDb.TVShowSeason? {
		do {
			return try await tmdb.tvShowSeasons.details(forSeason: season, inTVShow: id)
		} catch {
			return nil
		}
	}
    
    func fetchEpisode(_ episode: Int, forSeason season: Int, forTVSeries id: TMDb.TVShow.ID) async -> TMDb.TVShowEpisode? {
        do {
            return try await tmdb.tvShowEpisodes.details(forEpisode: episode, inSeason: season, inTVShow: id)
        } catch {
            return nil
        }
    }
	
	func fetchPoster(withID id: TMDb.TVShow.ID) async -> URL? {
		do {
			let images = try await tmdb.tvShows.images(forTVShow: id)
			return try await tmdb
                .configurations
                .apiConfiguration()
                .images
                .posterURL(for: images.posters
                    .first?.filePath, idealWidth: AppConstants.idealPosterWidth)
		} catch {
			return nil
		}
	}
	
	func fetchBackdrop(withID id: TMDb.TVShow.ID) async -> URL? {
		do {
			let images = try await tmdb.tvShows.images(forTVShow: id)
			return try await tmdb
                .configurations
                .apiConfiguration()
                .images
                .backdropURL(for: images.backdrops
                    .filter({$0.languageCode == nil})
                    .first?.filePath, idealWidth: AppConstants.idealBackdropWidth)
		} catch {
			return nil
		}
	}
    
    func fetchBackdropWithText(withID id: TMDb.TVShow.ID) async -> URL? {
        do {
            let images = try await tmdb.tvShows.images(forTVShow: id)
            return try await tmdb
                .configurations
                .apiConfiguration()
                .images
                .backdropURL(for: images.backdrops
                    .filter({$0.languageCode == AppConstants.languageCode})
                    .first?.filePath, idealWidth: AppConstants.idealBackdropWidth)
        } catch {
            return nil
        }
    }
	
	func fetchCredits(forTVShow id: TMDb.TVShow.ID) async -> TMDb.ShowCredits? {
		do {
			return try await tmdb.tvShows.credits(forTVShow: id)
		} catch {
			return nil
		}
	}
	
	func fetchRecommendations(forTVShow id: TMDb.TVShow.ID) async -> [TMDb.TVShow]? {
		do {
			return try await tmdb.tvShows.recommendations(forTVShow: id).results
		} catch {
			return nil
		}
	}
	
	func fetchDiscover(page: Int = 1) async -> [TMDb.TVShow]? {
		do {
			return try await tmdb.discover.tvShows(sortedBy: .popularity(descending: true), page: page).results
		} catch {
			return nil
		}
	}
	
	func fetchTrending(page: Int = 1) async -> [TMDb.TVShow]? {
		do {
			return try await tmdb.trending.tvShows(inTimeWindow: .week, page: page).results
		} catch {
			return nil
		}
	}
	
}
