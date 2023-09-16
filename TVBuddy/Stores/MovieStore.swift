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
	func movie(withID id: TMDb.Movie.ID) -> TMDb.Movie? {
        if movies[id] == nil {
            Task {
                let movie = await moviesManager.fetchMovie(withID: id)
                guard let movie = movie else { return }
                movies[id] = movie
            }
        }
        
        return movies[id]
	}
    
    @MainActor
	func poster(withID id: TMDb.Movie.ID) -> URL? {
        if posters[id] == nil {
            Task {
                let url = await moviesManager.fetchPoster(withID: id)
                guard let url = url else { return }
                posters[id] = url
            }
        }
        
		return posters[id]
	}
	
    @MainActor
	func backdrop(withID id: TMDb.Movie.ID) -> URL? {
        if backdrops[id] == nil {
            Task {
                let url = await moviesManager.fetchBackdrop(withID: id)
                guard let url = url else { return }
                backdrops[id] = url
            }
        }
        
		return backdrops[id]
	}
    
    @MainActor
    func backdropWithText(withID id: TMDb.Movie.ID) -> URL? {
        if backdropsWithText[id] == nil {
            Task {
                let url = await moviesManager.fetchBackdropWithText(withID: id)
                guard let url = url else { return }
                backdropsWithText[id] = url
            }
        }
        
        return backdropsWithText[id]
    }
    
    @MainActor
	func credits(forMovie id: TMDb.Movie.ID) -> TMDb.ShowCredits? {
        if credits[id] == nil {
            Task {
                let credits = await moviesManager.fetchCredits(forMovie: id)
                guard let credits = credits else { return }
                self.credits[id] = credits
            }
        }
        
		return credits[id]
	}
	
    @MainActor
	func recommendations(forMovie id: TMDb.Movie.ID) -> [TMDb.Movie]? {
        if recommendationsIDs[id] == nil {
            Task {
                let movies = await self.moviesManager.fetchRecommendations(forMovie: id)
                guard let movies = movies else { return }
                
                movies.forEach { movie in
                    _ = self.movie(withID: movie.id)
                }
                
                recommendationsIDs[id] = movies.compactMap { $0.id }
            }
        }
        
		return recommendationsIDs[id]?.compactMap { movies[$0] }
	}
    
    @MainActor
    func trending() -> [TMDb.Movie] {
        if trendingIDs.isEmpty {
            trendingPage = 1
            
            Task {
                let newPage = await moviesManager.fetchTrending(page: trendingPage)
                newPage?.forEach { movie in
                    _ = self.movie(withID: movie.id)
                    if !trendingIDs.contains(movie.id) { trendingIDs.append(movie.id) }
                }
            }
        }
        
        return trendingIDs.compactMap { movies[$0] }
    }
	
    @MainActor
    func discover() -> [TMDb.Movie] {
        if discoverIDs.isEmpty {
            discoverPage = 1
            
            Task {
                let newPage = await moviesManager.fetchDiscover(page: discoverPage)
                newPage?.forEach { movie in
                    _ = self.movie(withID: movie.id)
                    if !discoverIDs.contains(movie.id) { discoverIDs.append(movie.id) }
                }
            }
        }
        
        return discoverIDs.compactMap { movies[$0] }
    }
}

extension MovieStore {
	
//	@MainActor
//	func fetchDiscover() {
//		discoverPage += 1
//		
//		Task {
//			let newPage = await moviesManager.fetchDiscover(page: discoverPage)
//			
//			newPage?.forEach { movie in
//				if movies[movie.id] == nil {
//					movies[movie.id] = movie
//				}
//				
//				if !discoverIDs.contains(movie.id) {
//					discoverIDs.append(movie.id)
//				}
//			}
//		}
//	}
//	
//	@MainActor
//	func fetchNextDiscover(currentMovie: TMDb.Movie, offset: Int = AppConstants.nextPageOffset) {
//		let index = discoverIDs.firstIndex(where: { $0 == currentMovie.id })
//		let thresholdIndex = discoverIDs.endIndex - offset
//		guard index == thresholdIndex else {
//			return
//		}
//
//		fetchDiscover()
//	}
	
//	@MainActor
//	func fetchTrending() {
//		trendingPage += 1
//		
//		Task {
//			let newPage = await moviesManager.fetchTrending(page: trendingPage)
//			
//			newPage?.forEach { movie in
//				if movies[movie.id] == nil {
//					movies[movie.id] = movie
//				}
//				
//				if !trendingIDs.contains(movie.id) {
//					trendingIDs.append(movie.id)
//				}
//			}
//		}
//	}
//	
//	@MainActor
//	func fetchNextTrending(currentMovie: TMDb.Movie, offset: Int = AppConstants.nextPageOffset) {
//		let index = trendingIDs.firstIndex(where: { $0 == currentMovie.id })
//		let thresholdIndex = trendingIDs.endIndex - offset
//		guard index == thresholdIndex else {
//			return
//		}
//
//		fetchTrending()
//	}
	
}
