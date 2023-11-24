//
//  TVManager.swift
//  TVBuddy
//
//  Created by Danny on 07.07.22.
//

import Foundation
import TMDb

class TVManager {
    private let tvSeriesService = TVSeriesService()
    private let tvSeasonService = TVSeasonService()
    private let tvEpisodeService = TVEpisodeService()
    private let discoverService = AppConstants.discoverService
    private let trendingService = AppConstants.trendingService

    private var imageService: ImagesConfiguration? {
        AppConstants.apiConfiguration?.images
    }

    func fetchShow(id: TVSeries.ID) async -> TVSeries? {
        do {
            return try await tvSeriesService.details(forTVSeries: id)
        } catch {
            print(error)
            return nil
        }
    }

    func fetchSeason(season: Int, id: TVSeries.ID) async -> TVSeason? {
        do {
            return try await tvSeasonService.details(forSeason: season, inTVSeries: id)
        } catch {
            print(error)
            return nil
        }
    }

    func fetchEpisode(episode: Int, season: Int, id: TVSeries.ID) async -> TVEpisode? {
        do {
            return try await tvEpisodeService.details(forEpisode: episode, inSeason: season, inTVSeries: id)
        } catch {
            print(error)
            return nil
        }
    }

    func fetchPoster(id: TVSeries.ID, season: Int?) async -> URL? {
        do {
            let images: [ImageMetadata]
            if let season = season {
                images = try await tvSeasonService.images(forSeason: season, inTVSeries: id).posters
            } else {
                images = try await tvSeriesService.images(forTVSeries: id).posters
            }

            return imageService?.posterURL(
                for: images.first?.filePath,
                idealWidth: AppConstants.idealPosterWidth
            )
        } catch {
            print(error)
            return nil
        }
    }

    func fetchBackdrop(id: TVSeries.ID) async -> URL? {
        do {
            let images = try await tvSeriesService.images(forTVSeries: id).backdrops
            return imageService?.backdropURL(
                for: images.filter { $0.languageCode == nil }.first?.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        } catch {
            print(error)
            return nil
        }
    }

    func fetchBackdrop(id: TVSeries.ID, season: Int, episode: Int) async -> URL? {
        do {
            let images = try await tvEpisodeService.images(forEpisode: episode, inSeason: season, inTVSeries: id)
                .stills
                .filter { $0.languageCode == nil }
            
            if images.isEmpty {
                return await fetchBackdrop(id: id, season: season)
            }
            
            return imageService?.stillURL(
                for: images.first?.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        } catch {
            print(error)
            return await fetchBackdrop(id: id, season: season)
        }
    }

    func fetchBackdrop(id: TVSeries.ID, season: Int? = nil, episode: Int? = nil) async -> URL? {
        if let season = season, let episode = episode {
            return await fetchBackdrop(id: id, season: season, episode: episode)
        } else {
            return await fetchBackdrop(id: id)
        }
    }

    func fetchBackdropWithText(id: TVSeries.ID) async -> URL? {
        do {
            let images = try await tvSeriesService.images(forTVSeries: id)
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
            print(error)
            return nil
        }
    }

    func fetchCredits(id: TVSeries.ID) async -> ShowCredits? {
        do {
            return try await tvSeriesService.credits(forTVSeries: id)
        } catch {
            print(error)
            return nil
        }
    }

    func fetchRecommendations(id: TVSeries.ID, page: Int = 1) async -> [TVSeries]? {
        do {
            return try await tvSeriesService.recommendations(forTVSeries: id, page: page).results
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetchSimilar(id: TVSeries.ID, page: Int = 1) async -> [TVSeries]? {
        do {
            return try await tvSeriesService.similar(toTVSeries: id, page: page).results
        } catch {
            print(error)
            return nil
        }
    }

    func fetchDiscover(page: Int = 1) async -> [TVSeries]? {
        do {
            return try await discoverService.tvSeries(sortedBy: .popularity(descending: true), page: page).results
        } catch {
            print(error)
            return nil
        }
    }

    func fetchTrending(page: Int = 1) async -> [TVSeries]? {
        do {
            return try await trendingService.tvSeries(inTimeWindow: .week, page: page).results
        } catch {
            print(error)
            return nil
        }
    }
}
