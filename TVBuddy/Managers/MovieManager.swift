//
//  MovieManager.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import Foundation
import TMDb
import os

class MovieManager {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MovieManager.self)
    )

    private let movieService = AppConstants.tmdbClient.movies
    private let discoverService = AppConstants.tmdbClient.discover
    private let trendingService = AppConstants.tmdbClient.trending

    private var imageService: ImagesConfiguration? {
        AppConstants.apiConfiguration?.images
    }

    func fetchMovie(id: Movie.ID) async -> Movie? {
        do {
            return try await movieService.details(forMovie: id, language: AppConstants.languageCode)
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchImages(id: Movie.ID) async -> ImageCollection? {
        do {
            return try await movieService.images(
                forMovie: id,
                filter: MovieImageFilter(languages: [AppConstants.languageCode])
            )
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchCredits(id: Movie.ID) async -> ShowCredits? {
        do {
            return try await movieService.credits(forMovie: id, language: AppConstants.languageCode)
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchRecommendations(id: Movie.ID, page: Int = 1) async -> [Movie]? {
        do {
            return try await movieService.recommendations(
                forMovie: id,
                page: page,
                language: AppConstants.languageCode
            ).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchSimilar(id: Movie.ID, page: Int = 1) async -> [Movie]? {
        do {
            return try await movieService.similar(
                toMovie: id,
                page: page,
                language: AppConstants.languageCode
            ).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchDiscover(page: Int = 1) async -> [Movie]? {
        do {
            return try await discoverService.movies(
                sortedBy: .popularity(descending: true),
                page: page,
                language: AppConstants.languageCode
            ).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchTrending(page: Int = 1) async -> [Movie]? {
        do {
            return try await trendingService.movies(
                inTimeWindow: .week,
                page: page,
                language: AppConstants.languageCode
            ).results
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
