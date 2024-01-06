//
//  MovieManager.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import os
import Foundation
import TMDb

class MovieManager {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MovieManager.self)
    )
    
    private let movieService = MovieService()
    private let discoverService = AppConstants.discoverService
    private let trendingService = AppConstants.trendingService

    private var imageService: ImagesConfiguration? {
        AppConstants.apiConfiguration?.images
    }

    func fetchMovie(id: Movie.ID) async -> Movie? {
        do {
            return try await movieService.details(forMovie: id)
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchPoster(id: Movie.ID) async -> URL? {
        do {
            let images = try await movieService.images(forMovie: id).posters
            return imageService?.posterURL(
                for: images.first?.filePath,
                idealWidth: AppConstants.idealPosterWidth
            )
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchBackdrop(id: Movie.ID) async -> URL? {
        do {
            let images = try await movieService.images(forMovie: id).backdrops
            return imageService?.backdropURL(
                for: images.filter { $0.languageCode == nil }.first?.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchBackdropWithText(id: Movie.ID) async -> URL? {
        do {
            let images = try await movieService.images(forMovie: id)
                .backdrops
                .filter { $0.languageCode == AppConstants.languageCode }

            if images.isEmpty {
                return await fetchBackdrop(id: id)
            }

            return imageService?.backdropURL(
                for: images.first?.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchCredits(id: Movie.ID) async -> ShowCredits? {
        do {
            return try await movieService.credits(forMovie: id)
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchRecommendations(id: Movie.ID, page: Int = 1) async -> [Movie]? {
        do {
            return try await movieService.recommendations(forMovie: id, page: page).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchSimilar(id: Movie.ID, page: Int = 1) async -> [Movie]? {
        do {
            return try await movieService.similar(toMovie: id, page: page).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchDiscover(page: Int = 1) async -> [Movie]? {
        do {
            return try await discoverService.movies(sortedBy: .popularity(descending: true), page: page).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchTrending(page: Int = 1) async -> [Movie]? {
        do {
            return try await trendingService.movies(inTimeWindow: .week, page: page).results
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func handleError(_ error: any Error) {
        if let tmdbError = error as? TMDbError, case .network(let networkError) = tmdbError {
            if let nsError = networkError as NSError?, nsError.code == NSURLErrorCancelled {
                MovieManager.logger.info("Request cancelled")
                return
            }
        }
        
        MovieManager.logger.error("\(error.localizedDescription)")
        return
    }
}
