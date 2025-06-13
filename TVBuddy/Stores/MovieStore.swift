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

    private var imageService: ImagesConfiguration? {
        AppConstants.apiConfiguration?.images
    }

    private var movies: [Movie.ID: Movie] = [:]
    private var images: [Movie.ID: ImageCollection] = [:]
    private var credits: [Movie.ID: ShowCredits] = [:]
    private var recommendationsIDs: [Movie.ID: [Movie.ID]] = [:]
    private var similarIDs: [Movie.ID: [Movie.ID]] = [:]
    private var discoverIDs: [Movie.ID] = []
    private var trendingIDs: [Movie.ID] = []

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    @MainActor
    func movie(withID id: Movie.ID) async -> Movie? {
        if movies[id] == nil {
            let movie = await moviesManager.fetchMovie(id: id)
            guard let movie = movie else { return nil }

            movies[id] = movie
        }

        return movies[id]
    }

    @MainActor
    func images(id: Movie.ID) async -> ImageCollection? {
        if images[id] == nil {
            let imageCollection = await moviesManager.fetchImages(id: id)
            guard let imageCollection = imageCollection else { return nil }

            images[id] = imageCollection
        }

        return images[id]
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
        if credits[id] == nil {
            let credits = await moviesManager.fetchCredits(id: id)
            guard let credits = credits else { return nil }

            self.credits[id] = credits
        }

        return credits[id]
    }

    @MainActor
    func recommendations(forMovie id: Movie.ID) async -> [Movie]? {
        if recommendationsIDs[id] == nil {
            let movies = await moviesManager.fetchRecommendations(id: id)
            guard let movies = movies else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for movie in movies {
                    taskGroup.addTask {
                        _ = await self.movie(withID: movie.id)
                    }
                }
            }

            recommendationsIDs[id] = movies.compactMap { $0.id }
        }

        return recommendationsIDs[id]!.compactMap { self.movies[$0] }
    }

    @MainActor
    func similar(toMovie id: Movie.ID) async -> [Movie]? {
        if similarIDs[id] == nil {
            let movies = await moviesManager.fetchSimilar(id: id)
            guard let movies = movies else { return nil }

            await withTaskGroup(of: Void.self) { taskGroup in
                for movie in movies {
                    taskGroup.addTask {
                        _ = await self.movie(withID: movie.id)
                    }
                }
            }

            similarIDs[id] = movies.compactMap { $0.id }
        }

        return similarIDs[id]!.compactMap { self.movies[$0] }
    }

    @MainActor
    func trending(newPage: Bool = false) async -> [Movie] {
        if !newPage && trendingPage != 0 {
            return trendingIDs.compactMap { movies[$0] }
        }

        let nextPageNumber = trendingPage + 1

        let page = await moviesManager.fetchTrending(page: nextPageNumber)
        guard let page = page else { return [] }

        await withTaskGroup(of: Void.self) { taskGroup in
            for movie in page {
                taskGroup.addTask {
                    _ = await self.movie(withID: movie.id)
                }
            }
        }

        page.forEach { movie in
            if !self.trendingIDs.contains(movie.id) {
                self.trendingIDs.append(movie.id)
            }
        }

        trendingPage = max(nextPageNumber, trendingPage)
        return trendingIDs.compactMap { self.movies[$0] }
    }

    @MainActor
    func discover(newPage: Bool = false) async -> [Movie] {
        if !newPage && discoverPage != 0 {
            return discoverIDs.compactMap { movies[$0] }
        }

        let nextPageNumber = discoverPage + 1

        let page = await moviesManager.fetchDiscover(page: nextPageNumber)
        guard let page = page else { return [] }

        await withTaskGroup(of: Void.self) { taskGroup in
            for movie in page {
                taskGroup.addTask {
                    _ = await self.movie(withID: movie.id)
                }
            }
        }

        page.forEach { movie in
            if !self.discoverIDs.contains(movie.id) {
                self.discoverIDs.append(movie.id)
            }
        }

        discoverPage = max(nextPageNumber, discoverPage)
        return discoverIDs.compactMap { self.movies[$0] }
    }
}
