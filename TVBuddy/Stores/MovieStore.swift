//
//  MovieStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class MovieStore: ObservableObject {
    private let moviesManager: MovieManager

    @Published var movies: [Movie.ID: Movie] = [:]
    @Published var posters: [Movie.ID: URL] = [:]
    @Published var backdrops: [Movie.ID: URL] = [:]
    @Published var backdropsWithText: [Movie.ID: URL] = [:]
    @Published var credits: [Movie.ID: ShowCredits] = [:]
    @Published var recommendationsIDs: [Movie.ID: [Movie.ID]] = [:]
    @Published var discoverIDs: [Movie.ID] = []
    @Published var trendingIDs: [Movie.ID] = []

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    init(moviesManager: MovieManager = MovieManager()) {
        self.moviesManager = moviesManager
    }

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
    func trending() async -> [Movie] {
        if trendingPage == 1 {
            return trendingIDs.compactMap { movies[$0] }
        }

        trendingPage = 1

        let page = await moviesManager.fetchTrending(page: trendingPage)
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

        return trendingIDs.compactMap { movies[$0] }
    }

    @MainActor
    func discover() async -> [Movie] {
        if discoverPage == 1 {
            return discoverIDs.compactMap { movies[$0] }
        }

        discoverPage = 1

        let page = await moviesManager.fetchDiscover(page: trendingPage)
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

        return discoverIDs.compactMap { movies[$0] }
    }
}

extension MovieStore {
    //    @MainActor
    //    func fetchDiscover() {
    //        discoverPage += 1
    //
    //        Task {
    //            let newPage = await moviesManager.fetchDiscover(page: discoverPage)
    //
    //            newPage?.forEach { movie in
    //                if movies[movie.id] == nil {
    //                    movies[movie.id] = movie
    //                }
    //
    //                if !discoverIDs.contains(movie.id) {
    //                    discoverIDs.append(movie.id)
    //                }
    //            }
    //        }
    //    }
    //
    //    @MainActor
    //    func fetchNextDiscover(currentMovie: Movie, offset: Int = AppConstants.nextPageOffset) {
    //        let index = discoverIDs.firstIndex(where: { $0 == currentMovie.id })
    //        let thresholdIndex = discoverIDs.endIndex - offset
    //        guard index == thresholdIndex else {
    //            return
    //        }
    //
    //        fetchDiscover()
    //    }

    //    @MainActor
    //    func fetchTrending() {
    //        trendingPage += 1
    //
    //        Task {
    //            let newPage = await moviesManager.fetchTrending(page: trendingPage)
    //
    //            newPage?.forEach { movie in
    //                if movies[movie.id] == nil {
    //                    movies[movie.id] = movie
    //                }
    //
    //                if !trendingIDs.contains(movie.id) {
    //                    trendingIDs.append(movie.id)
    //                }
    //            }
    //        }
    //    }
    //
    //    @MainActor
    //    func fetchNextTrending(currentMovie: Movie, offset: Int = AppConstants.nextPageOffset) {
    //        let index = trendingIDs.firstIndex(where: { $0 == currentMovie.id })
    //        let thresholdIndex = trendingIDs.endIndex - offset
    //        guard index == thresholdIndex else {
    //            return
    //        }
    //
    //        fetchTrending()
    //    }
}
