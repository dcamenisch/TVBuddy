//
//  TVManager.swift
//  TVBuddy
//
//  Created by Danny on 07.07.22.
//

import os
import Foundation
import TMDb

class TVManager {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TVManager.self)
    )
    
    private let tvSeriesService = AppConstants.tmdbClient.tvSeries
    private let tvSeasonService = AppConstants.tmdbClient.tvSeasons
    private let tvEpisodeService = AppConstants.tmdbClient.tvEpisodes
    
    private let discoverService = AppConstants.tmdbClient.discover
    private let trendingService = AppConstants.tmdbClient.trending

    func fetchShow(id: TVSeries.ID) async -> TVSeries? {
        do {
            return try await tvSeriesService.details(
                forTVSeries: id,
                language: AppConstants.languageCode
            )
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchSeason(season: Int, id: TVSeries.ID) async -> TVSeason? {
        do {
            return try await tvSeasonService.details(
                forSeason: season,
                inTVSeries: id,
                language: AppConstants.languageCode
            )
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchEpisode(episode: Int, season: Int, id: TVSeries.ID) async -> TVEpisode? {
        do {
            return try await tvEpisodeService.details(
                forEpisode: episode,
                inSeason: season,
                inTVSeries: id,
                language: AppConstants.languageCode
            )
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func fetchImages(id: Int) async -> ImageCollection? {
        do {
            return try await tvSeriesService.images(
                forTVSeries: id,
                filter: TVSeriesImageFilter(languages: [AppConstants.languageCode])
            )
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func fetchImages(season: Int, id: Int) async -> TVSeasonImageCollection? {
        do {
            return try await tvSeasonService.images(
                forSeason: season,
                inTVSeries: id,
                filter: TVSeasonImageFilter(languages: [AppConstants.languageCode])
            )
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func fetchImages(episode: Int, season: Int, id: Int) async -> TVEpisodeImageCollection? {
        do {
            return try await tvEpisodeService.images(
                forEpisode: episode,
                inSeason: season,
                inTVSeries: id
            )
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchCredits(id: TVSeries.ID) async -> ShowCredits? {
        do {
            return try await tvSeriesService.credits(
                forTVSeries: id,
                language: AppConstants.languageCode
            )
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func fetchAggregateCredits(id: TVSeries.ID) async -> TVSeriesAggregateCredits? {
            do {
                return try await tvSeriesService.aggregateCredits(
                    forTVSeries: id,
                    language: AppConstants.languageCode
                )
            } catch {
                handleError(error)
                return nil
            }
        }
    
    func fetchRecommendations(id: TVSeries.ID, page: Int = 1) async -> [TVSeries]? {
        do {
            return try await tvSeriesService.recommendations(
                forTVSeries: id,
                page: page,
                language: AppConstants.languageCode
            ).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchSimilar(id: TVSeries.ID, page: Int = 1) async -> [TVSeries]? {
        do {
            return try await tvSeriesService.similar(
                toTVSeries: id,
                page: page,
                language: AppConstants.languageCode
            ).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchDiscover(page: Int = 1) async -> [TVSeries]? {
        do {
            return try await discoverService.tvSeries(
                sortedBy: .popularity(descending: true),
                page: page,
                language: AppConstants.languageCode
            ).results
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchTrending(page: Int = 1) async -> [TVSeries]? {
        do {
            return try await trendingService.tvSeries(
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
                TVManager.logger.info("Request cancelled")
                return
            }
        }
        
        TVManager.logger.error("\(error.localizedDescription)")
        return
    }
}
