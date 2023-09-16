//
//  TMDbMovieManager.swift
//  tvTracker
//
//  Created by Danny on 02.07.22.
//

import Foundation
import TMDb

class MovieManager {
	
	private let tmdb = AppConstants.tmdb
	
	func fetchMovie(withID id: TMDb.Movie.ID) async -> TMDb.Movie? {
		do {
			return try await tmdb.movies.details(forMovie: id)
		} catch {
			return nil
		}
	}
	
	func fetchPoster(withID id: TMDb.Movie.ID) async -> URL? {
		do {
			let images = try await tmdb.movies.images(forMovie: id)
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
	
	func fetchBackdrop(withID id: TMDb.Movie.ID) async -> URL? {
		do {
			let images = try await tmdb.movies.images(forMovie: id)
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
    
    func fetchBackdropWithText(withID id: TMDb.Movie.ID) async -> URL? {
        do {
            let images = try await tmdb.movies.images(forMovie: id)
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
	
	func fetchCredits(forMovie id: TMDb.Movie.ID) async -> TMDb.ShowCredits? {
		do {
			return try await tmdb.movies.credits(forMovie: id)
		} catch {
			return nil
		}
	}
	
	func fetchRecommendations(forMovie id: TMDb.Movie.ID) async -> [TMDb.Movie]? {
		do {
			return try await tmdb.movies.recommendations(forMovie: id).results
		} catch {
			return nil
		}
	}
	
	func fetchDiscover(page: Int = 1) async -> [TMDb.Movie]? {
		do {
			return try await tmdb.discover.movies(sortedBy: .popularity(descending: true), page: page).results
		} catch {
			return nil
		}
	}
	
	func fetchTrending(page: Int = 1) async -> [TMDb.Movie]? {
		do {
			return try await tmdb.trending.movies(inTimeWindow: .week, page: page).results
		} catch {
			return nil
		}
	}
	
}
