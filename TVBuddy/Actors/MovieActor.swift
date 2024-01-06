//
//  MovieActor.swift
//  TVBuddy
//
//  Created by Danny on 06.01.2024.
//

import os
import SwiftData
import SwiftUI
import TMDb

@ModelActor
actor MovieActor {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MovieActor.self)
    )
    
    func insertMovie(id: Movie.ID, watched: Bool) async {
        do {
            let movie = await MovieStore.shared.movie(withID: id)
        
            guard let movie = movie else {
                return
            }
        
            modelContext.insert(TVBuddyMovie(movie: movie, watched: watched))
            try modelContext.save()
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }
    
    func updateMovies() async {
        do {
            let now = Date.now
            let future = Date.distantFuture
            
            let predicate = #Predicate<TVBuddyMovie> {$0.releaseDate ?? future >= now }
            let tvbMovies = try modelContext.fetch(FetchDescriptor<TVBuddyMovie>(predicate: predicate))
            
            for tvbMovie in tvbMovies {
                if let movie = await MovieStore.shared.movie(withID: tvbMovie.id) {
                    tvbMovie.update(movie: movie)
                    MovieActor.logger.info("Updated movie: \(movie.title)")
                }
            }
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }
}
