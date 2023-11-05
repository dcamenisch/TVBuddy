//
//  MovieStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class MovieStore: ObservableObject {
    
    private let fetchMovieQueue           = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchMovieQueue")
    private let fetchPosterQueue          = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchPosterQueue")
    private let fetchBackdropQueue        = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchBackdropQueue")
    private let fetchBackdropTextQueue    = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchBackdropTextQueue")
    private let fetchCreditsQueue         = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchCreditsQueue")
    private let fetchRecommendationsQueue = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchRecommendationsQueue")
    private let fetchTrendingQueue        = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchTrendingQueue")
    private let fetchDiscoverQueue        = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchDiscoverQueue")
    
    private var pendingFetchMovieTasks: [TMDb.Movie.ID: Task<(), Never>]           = [:]
    private var pendingFetchPosterTasks: [TMDb.Movie.ID: Task<(), Never>]          = [:]
    private var pendingFetchBackdropTasks: [TMDb.Movie.ID: Task<(), Never>]        = [:]
    private var pendingFetchBackdropTextTasks: [TMDb.Movie.ID: Task<(), Never>]    = [:]
    private var pendingFetchCreditsTasks: [TMDb.Movie.ID: Task<(), Never>]         = [:]
    private var pendingFetchRecommendationsTasks: [TMDb.Movie.ID: Task<(), Never>] = [:]
    private var pendingFetchTrendingTask: [Int: Task<(), Never>]                   = [:]
    private var pendingFetchDiscoverTask: [Int: Task<(), Never>]                   = [:]

	private let moviesManager: MovieManager
	
	@Published var movies: [TMDb.Movie.ID: TMDb.Movie]                  = [:]
	@Published var posters: [TMDb.Movie.ID: URL]                        = [:]
	@Published var backdrops: [TMDb.Movie.ID: URL]                      = [:]
    @Published var backdropsWithText: [TMDb.Movie.ID: URL]              = [:]
	@Published var credits: [TMDb.Movie.ID: TMDb.ShowCredits]           = [:]
	@Published var recommendationsIDs: [TMDb.Movie.ID: [TMDb.Movie.ID]] = [:]
	@Published var discoverIDs: [TMDb.Movie.ID]                         = []
	@Published var trendingIDs: [TMDb.Movie.ID]                         = []
	
	private var discoverPage: Int = 0
	private var trendingPage: Int = 0
	
	init(moviesManager: MovieManager = MovieManager()) {
		self.moviesManager = moviesManager
	}
    
    @MainActor
	func movie(withID id: TMDb.Movie.ID) -> TMDb.Movie? {
        if let movie = movies[id] {
            return movie
        }
        
        if pendingFetchMovieTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let movie = await moviesManager.fetchMovie(withID: id)
            if let movie = movie {
                movies[id] = movie
            }
            
            fetchMovieQueue.sync {
                pendingFetchMovieTasks[id] = nil
            }
        }

        fetchMovieQueue.sync {
            pendingFetchMovieTasks[id] = fetchTask
        }

        return nil
	}
    
    @MainActor
	func poster(withID id: TMDb.Movie.ID) -> URL? {
        if let url = posters[id] {
            return url
        }
        
        if pendingFetchPosterTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let url = await moviesManager.fetchPoster(withID: id)
            if let url = url {
                posters[id] = url
            }
            
            fetchPosterQueue.sync {
                pendingFetchPosterTasks[id] = nil
            }
        }

        fetchPosterQueue.sync {
            pendingFetchPosterTasks[id] = fetchTask
        }

        return nil
	}
	
    @MainActor
	func backdrop(withID id: TMDb.Movie.ID) -> URL? {
        if let url = backdrops[id] {
            return url
        }
        
        if pendingFetchBackdropTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let url = await moviesManager.fetchBackdrop(withID: id)
            if let url = url {
                backdrops[id] = url
            }
            
            fetchBackdropQueue.sync {
                pendingFetchBackdropTasks[id] = nil
            }
        }

        fetchBackdropQueue.sync {
            pendingFetchBackdropTasks[id] = fetchTask
        }

        return nil
	}
    
    @MainActor
    func backdropWithText(withID id: TMDb.Movie.ID) -> URL? {
        if let url = backdropsWithText[id] {
            return url
        }
        
        if pendingFetchBackdropTextTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let url = await moviesManager.fetchBackdropWithText(withID: id)
            if let url = url {
                backdropsWithText[id] = url
            }
            
            fetchBackdropTextQueue.sync {
                pendingFetchBackdropTextTasks[id] = nil
            }
        }

        fetchBackdropTextQueue.sync {
            pendingFetchBackdropTextTasks[id] = fetchTask
        }

        return nil
    }
    
    @MainActor
	func credits(forMovie id: TMDb.Movie.ID) -> TMDb.ShowCredits? {
        if let credits = self.credits[id] {
            return credits
        }
        
        if pendingFetchCreditsTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let credits = await moviesManager.fetchCredits(forMovie: id)
            if let credits = credits {
                self.credits[id] = credits
            }
            
            fetchCreditsQueue.sync {
                pendingFetchCreditsTasks[id] = nil
            }
        }

        fetchCreditsQueue.sync {
            pendingFetchCreditsTasks[id] = fetchTask
        }

        return nil
	}
	
    @MainActor
	func recommendations(forMovie id: TMDb.Movie.ID) -> [TMDb.Movie]? {
        if let movies = recommendationsIDs[id] {
            return movies.compactMap { self.movies[$0] }
        }
        
        if pendingFetchRecommendationsTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let movies = await moviesManager.fetchRecommendations(forMovie: id)?.prefix(10)
            if let movies = movies {
                movies.forEach { movie in
                    _ = self.movie(withID: movie.id)
                }
                
                recommendationsIDs[id] = movies.compactMap { $0.id }
            }
            
            fetchRecommendationsQueue.sync {
                pendingFetchRecommendationsTasks[id] = nil
            }
        }

        fetchRecommendationsQueue.sync {
            pendingFetchRecommendationsTasks[id] = fetchTask
        }

        return nil
	}
    
    @MainActor
    func trending() -> [TMDb.Movie] {
        if trendingPage == 1 {
            return trendingIDs.compactMap { movies[$0] }
        }
        
        trendingPage = 1
        
        if pendingFetchTrendingTask[trendingPage] != nil {
            return trendingIDs.compactMap { movies[$0] }
        }
        
        let fetchTask = Task {
            let newPage = await moviesManager.fetchTrending(page: trendingPage)
            
            newPage?.forEach { movie in
                _ = self.movie(withID: movie.id)
                if !trendingIDs.contains(movie.id) { trendingIDs.append(movie.id) }
            }
        
            fetchTrendingQueue.sync {
                pendingFetchRecommendationsTasks[trendingPage] = nil
            }
        }
        
        fetchTrendingQueue.sync {
            pendingFetchTrendingTask[trendingPage] = fetchTask
        }
        
        return trendingIDs.compactMap { movies[$0] }
    }
	
    @MainActor
    func discover() -> [TMDb.Movie] {
        if discoverPage == 1 {
            return discoverIDs.compactMap { movies[$0] }
        }
        
        discoverPage = 1
        
        if pendingFetchDiscoverTask[discoverPage] != nil {
            return discoverIDs.compactMap { movies[$0] }
        }
        
        let fetchTask = Task {
            let newPage = await moviesManager.fetchDiscover(page: trendingPage)
            
            newPage?.forEach { movie in
                _ = self.movie(withID: movie.id)
                if !discoverIDs.contains(movie.id) { discoverIDs.append(movie.id) }
            }
        
            fetchDiscoverQueue.sync {
                pendingFetchDiscoverTask[discoverPage] = nil
            }
        }
        
        fetchDiscoverQueue.sync {
            pendingFetchDiscoverTask[discoverPage] = fetchTask
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
