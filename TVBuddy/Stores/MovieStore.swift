//
//  MovieStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class MovieStore {
    static let shared = MovieStore()
    
    private let moviesManager: MovieManager = MovieManager()

    var movies: [Movie.ID: Movie] = [:]
    var posters: [Movie.ID: URL] = [:]
    var backdrops: [Movie.ID: URL] = [:]
    var backdropsWithText: [Movie.ID: URL] = [:]
    var credits: [Movie.ID: ShowCredits] = [:]
    var recommendationsIDs: [Movie.ID: [Movie.ID]] = [:]
    var similarIDs: [Movie.ID: [Movie.ID]] = [:]
    var discoverIDs: [Movie.ID] = []
    var trendingIDs: [Movie.ID] = []

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    private init() {}

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
    func poster(withID id: Movie.ID) async -> URL? {
        if posters[id] == nil {
            let url = await moviesManager.fetchPoster(id: id)
            guard let url = url else { return nil }

            posters[id] = url
        }

        return posters[id]
    }

    @MainActor
    func backdrop(withID id: Movie.ID) async -> URL? {
        if backdrops[id] == nil {
            let url = await moviesManager.fetchBackdrop(id: id)
            guard let url = url else { return nil }

            backdrops[id] = url
        }

        return backdrops[id]
    }

    @MainActor
    func backdropWithText(withID id: Movie.ID) async -> URL? {
        if backdropsWithText[id] == nil {
            let url = await moviesManager.fetchBackdropWithText(id: id)
            guard let url = url else { return nil }

            backdropsWithText[id] = url
        }

        return backdropsWithText[id]
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
            if !self.trendingIDs.contains(movie.id) { self.trendingIDs.append(movie.id) }
        }

        trendingPage = max(nextPageNumber, trendingPage)
        return trendingIDs.compactMap { movies[$0] }
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
            if !self.discoverIDs.contains(movie.id) { self.discoverIDs.append(movie.id) }
        }

        discoverPage = max(nextPageNumber, discoverPage)
        return discoverIDs.compactMap { movies[$0] }
    }
}
