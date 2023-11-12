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

    @Published var movies: [TMDb.Movie.ID: TMDb.Movie] = [:]
    @Published var posters: [TMDb.Movie.ID: URL] = [:]
    @Published var backdrops: [TMDb.Movie.ID: URL] = [:]
    @Published var backdropsWithText: [TMDb.Movie.ID: URL] = [:]
    @Published var credits: [TMDb.Movie.ID: TMDb.ShowCredits] = [:]
    @Published var recommendationsIDs: [TMDb.Movie.ID: [TMDb.Movie.ID]] = [:]
    @Published var discoverIDs: [TMDb.Movie.ID] = []
    @Published var trendingIDs: [TMDb.Movie.ID] = []

    private var discoverPage: Int = 0
    private var trendingPage: Int = 0

    init(moviesManager: MovieManager = MovieManager()) {
        self.moviesManager = moviesManager
    }
    
    @MainActor
    func movie(withID id: TMDb.Movie.ID) async -> TMDb.Movie? {
        if self.movies[id] == nil {
            let movie = await moviesManager.fetchMovie(withID: id)
            guard let movie = movie else { return nil }
            
            self.movies[id] = movie
        }
        
        return self.movies[id]
    }
    
    @MainActor
    func poster(withID id: TMDb.Movie.ID) async -> URL? {
        if self.posters[id] == nil {
            let url = await moviesManager.fetchPoster(withID: id)
            guard let url = url else { return nil }
            
            self.posters[id] = url
        }
        
        return self.posters[id]
    }
    
    @MainActor
    func backdrop(withID id: TMDb.Movie.ID) async -> URL? {
        if self.backdrops[id] == nil {
            let url = await moviesManager.fetchBackdrop(withID: id)
            guard let url = url else { return nil }
            
            self.backdrops[id] = url
        }
        
        return self.backdrops[id]
    }
    
    @MainActor
    func backdropWithText(withID id: TMDb.Movie.ID) async -> URL? {
        if self.backdropsWithText[id] == nil {
            let url = await moviesManager.fetchBackdropWithText(withID: id)
            guard let url = url else { return nil }
            
            self.backdropsWithText[id] = url
        }
        
        return self.backdropsWithText[id]
    }
    
    @MainActor
    func credits(forMovie id: TMDb.Movie.ID) async -> TMDb.ShowCredits? {
        if self.credits[id] == nil {
            let credits = await moviesManager.fetchCredits(forMovie: id)
            guard let credits = credits else { return nil }
            
            self.credits[id] = credits
        }
        
        return self.credits[id]
    }
    
    @MainActor
    func recommendations(forMovie id: TMDb.Movie.ID) async -> [TMDb.Movie]? {
        if self.recommendationsIDs[id] == nil {
            let movies = await moviesManager.fetchRecommendations(forMovie: id)
            guard let movies = movies else { return nil }
            
            await withTaskGroup(of: Void.self) { taskGroup in
                for movie in movies {
                    taskGroup.addTask {
                        _ = await self.movie(withID: movie.id)
                    }
                }
            }
            
            self.recommendationsIDs[id] = movies.compactMap { $0.id }
        }
        
        return self.recommendationsIDs[id]!.compactMap { self.movies[$0] }
    }
    
    @MainActor
    func trending() async -> [TMDb.Movie] {
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
    func discover() async -> [TMDb.Movie] {
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
    //    func fetchNextDiscover(currentMovie: TMDb.Movie, offset: Int = AppConstants.nextPageOffset) {
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
    //    func fetchNextTrending(currentMovie: TMDb.Movie, offset: Int = AppConstants.nextPageOffset) {
    //        let index = trendingIDs.firstIndex(where: { $0 == currentMovie.id })
    //        let thresholdIndex = trendingIDs.endIndex - offset
    //        guard index == thresholdIndex else {
    //            return
    //        }
    //
    //        fetchTrending()
    //    }

}
