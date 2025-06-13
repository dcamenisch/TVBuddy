//
//  MovieStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class MovieStore {
    private let movieCache = CacheService<Movie.ID, Movie>()
    private let imageCache = CacheService<Movie.ID, ImageCollection>()
    private let creditCache = CacheService<Movie.ID, ShowCredits>()
    private let recommendationsCache = CacheService<Movie.ID, [Movie.ID]>()
    private let similarMoviesCache = CacheService<Movie.ID, [Movie.ID]>()
    private let discoverMoviesCache = CacheService<String, [Movie.ID]>()
    private let trendingMoviesCache = CacheService<String, [Movie.ID]>()

    static let shared = MovieStore()

    private let moviesManager: MovieManager = MovieManager()

    private var imageService: ImagesConfiguration? { AppConstants.apiConfiguration?.images }

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    @MainActor
    func movie(withID id: Movie.ID) async -> Movie? {
        if let cachedMovie = movieCache.object(forKey: id) {
            return cachedMovie
        }

        let movie = await moviesManager.fetchMovie(id: id)
        guard let movie else { return nil }

        movieCache.setObject(movie, forKey: id)
        return movie
    }

    @MainActor
    func images(id: Movie.ID) async -> ImageCollection? {
        if let cachedImages = imageCache.object(forKey: id) {
            return cachedImages
        }

        let imageCollection = await moviesManager.fetchImages(id: id)
        guard let imageCollection = imageCollection else { return nil }

        imageCache.setObject(imageCollection, forKey: id)
        return imageCollection
    }

    @MainActor
    func logos(id: Movie.ID) async -> [URL] {
        guard let images = await images(id: id) else { return [] }

        return images.logos.compactMap { logo in
            imageService?.logoURL(
                for: logo.filePath
            )
        }
    }

    @MainActor
    func posters(withID id: Movie.ID) async -> [URL] {
        guard let images = await images(id: id) else { return [] }

        var posters = images.posters.filter { $0.languageCode != nil }
        posters = posters.isEmpty ? images.posters : posters

        return posters.compactMap { poster in
            imageService?.posterURL(
                for: poster.filePath,
                idealWidth: AppConstants.idealPosterWidth
            )
        }
    }

    @MainActor
    func backdrops(withID id: Movie.ID) async -> [URL] {
        guard let images = await images(id: id) else { return [] }
        let backdrops = images.backdrops.filter { $0.languageCode == nil }

        return backdrops.compactMap { backdrop in
            imageService?.backdropURL(
                for: backdrop.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        }
    }

    @MainActor
    func backdropsWithText(withID id: Movie.ID) async -> [URL] {
        guard let images = await images(id: id) else { return [] }

        var backdrops = images.backdrops.filter { $0.languageCode != nil }
        backdrops = backdrops.isEmpty ? images.backdrops : backdrops

        return backdrops.compactMap { backdrop in
            imageService?.backdropURL(
                for: backdrop.filePath,
                idealWidth: AppConstants.idealBackdropWidth
            )
        }
    }

    @MainActor
    func credits(forMovie id: Movie.ID) async -> ShowCredits? {
        if let cachedCredits = creditCache.object(forKey: id) {
            return cachedCredits
        }

        let credits = await moviesManager.fetchCredits(id: id)
        guard let credits = credits else { return nil }

        creditCache.setObject(credits, forKey: id)
        return credits
    }

    @MainActor
    func recommendations(forMovie id: Movie.ID) async -> [Movie]? {
        var movieIDs: [Movie.ID]? = recommendationsCache.object(forKey: id)

        if movieIDs == nil {
            let fetchedMovies = await moviesManager.fetchRecommendations(id: id)
            guard let fetchedMovies = fetchedMovies else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for movie in fetchedMovies {
                    taskGroup.addTask {
                        // This will populate movieCache
                        _ = await self.movie(withID: movie.id)
                    }
                }
            }
            let ids = fetchedMovies.map { $0.id }
            recommendationsCache.setObject(ids, forKey: id)
            movieIDs = ids
        }

        guard let finalMovieIDs = movieIDs else { return [] }

        var resultMovies: [Movie] = []
        for movieID in finalMovieIDs {
            if let movie = await self.movie(withID: movieID) {
                resultMovies.append(movie)
            }
        }
        return resultMovies
    }

    @MainActor
    func similar(toMovie id: Movie.ID) async -> [Movie]? {
        var movieIDs: [Movie.ID]? = similarMoviesCache.object(forKey: id)

        if movieIDs == nil {
            let fetchedMovies = await moviesManager.fetchSimilar(id: id)
            guard let fetchedMovies = fetchedMovies else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for movie in fetchedMovies {
                    taskGroup.addTask {
                        // This will populate movieCache
                        _ = await self.movie(withID: movie.id)
                    }
                }
            }
            let ids = fetchedMovies.map { $0.id }
            similarMoviesCache.setObject(ids, forKey: id)
            movieIDs = ids
        }

        guard let finalMovieIDs = movieIDs else { return [] }

        var resultMovies: [Movie] = []
        for movieID in finalMovieIDs {
            if let movie = await self.movie(withID: movieID) {
                resultMovies.append(movie)
            }
        }
        return resultMovies
    }

    func trending(newPage: Bool = false) async -> [Movie] {
        let cacheKey = "trendingMovies"
        var trendingIDs: [Movie.ID]? = trendingMoviesCache.object(forKey: cacheKey)

        if newPage || trendingIDs == nil {
            if newPage && trendingIDs == nil {
                // e.g. cache expired and requesting new page
                // don't increment page if cache expired and not explicitly requesting new page
            } else if newPage {
                trendingPage += 1
            } else {
                trendingPage = 1
            }

            let pageItems = await moviesManager.fetchTrending(page: trendingPage)
            guard let pageItems = pageItems else {
                if trendingIDs == nil { trendingMoviesCache.removeObject(forKey: cacheKey) }
                return []
            }

            await withTaskGroup(of: Void.self) { taskGroup in
                for movie in pageItems {
                    taskGroup.addTask {
                        // Populates movieCache
                        _ = await self.movie(withID: movie.id)
                    }
                }
            }

            var currentTrendingIDs = newPage ? (trendingIDs ?? []) : []
            pageItems.forEach { movie in
                if !currentTrendingIDs.contains(movie.id) { currentTrendingIDs.append(movie.id) }
            }
            trendingMoviesCache.setObject(currentTrendingIDs, forKey: cacheKey)
            trendingIDs = currentTrendingIDs
        }

        guard let finalTrendingIDs = trendingIDs else { return [] }

        var resultMovies: [Movie] = []
        for movieID in finalTrendingIDs {
            if let movie = await self.movie(withID: movieID) {
                resultMovies.append(movie)
            }
        }
        return resultMovies
    }

    @MainActor
    func discover(newPage: Bool = false) async -> [Movie] {
        let cacheKey = "discoverMovies"
        var discoverIDs: [Movie.ID]? = discoverMoviesCache.object(forKey: cacheKey)

        if newPage || discoverIDs == nil {
            if newPage && discoverIDs == nil {
                // e.g. cache expired and requesting new page
                // don't increment page if cache expired and not explicitly requesting new page
            } else if newPage {
                discoverPage += 1
            } else {
                discoverPage = 1
            }

            let pageItems = await moviesManager.fetchDiscover(page: discoverPage)
            guard let pageItems = pageItems else {
                if discoverIDs == nil { discoverMoviesCache.removeObject(forKey: cacheKey) }
                return []
            }

            await withTaskGroup(of: Void.self) { taskGroup in
                for movie in pageItems {
                    taskGroup.addTask {
                        // Populates movieCache
                        _ = await self.movie(withID: movie.id)
                    }
                }
            }

            var currentDiscoverIDs = newPage ? (discoverIDs ?? []) : []
            pageItems.forEach { movie in
                if !currentDiscoverIDs.contains(movie.id) { currentDiscoverIDs.append(movie.id) }
            }
            discoverMoviesCache.setObject(currentDiscoverIDs, forKey: cacheKey)
            discoverIDs = currentDiscoverIDs
        }

        guard let finalDiscoverIDs = discoverIDs else { return [] }

        var resultMovies: [Movie] = []
        for movieID in finalDiscoverIDs {
            if let movie = await self.movie(withID: movieID) {
                resultMovies.append(movie)
            }
        }
        return resultMovies
    }
}
