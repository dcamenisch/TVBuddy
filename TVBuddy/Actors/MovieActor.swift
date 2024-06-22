//
//  MovieActor.swift
//  TVBuddy
//
//  Created by Danny on 06.01.2024.
//

import SwiftData
import SwiftUI
import TMDb
import os

/// An actor responsible for managing movie-related operations in the TVBuddy app.
/// Utilizes concurrency to safely access and modify movie data.
@ModelActor
actor MovieActor {
    /// Logger for the MovieActor class, used to log information and errors.
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MovieActor.self)
    )

    /// Inserts a new movie into the database.
    /// - Parameters:
    ///   - id: The TMDb identifier of the movie to insert.
    ///   - watched: A Boolean value indicating whether the movie has been watched.
    func insertMovie(id: Movie.ID, watched: Bool) async {
        do {
            let movie = await MovieStore.shared.movie(withID: id)

            guard let movie = movie else { return }
            
            modelContext.insert(TVBuddyMovie(movie: movie, watched: watched))
            try modelContext.save()
            
            MovieActor.logger.info("Inserted movie \(movie.title)")
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Deletes a movie from the database.
    /// - Parameter id: The TMDb identifier of the movie to delete.
    func deleteMovie(id: Movie.ID) async {
        do {
            let predicate = #Predicate<TVBuddyMovie> { $0.id == id }
            let tvbMovie = try modelContext.fetch(
                FetchDescriptor<TVBuddyMovie>(predicate: predicate)
            ).first

            guard let tvbMovie = tvbMovie else { return }

            modelContext.delete(tvbMovie)
            try modelContext.save()

            MovieActor.logger.info("Deleted movie \(tvbMovie.title)")
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Updates the details of all movies in the database with
    /// a release date in the future.
    func updateMovies() async {
        do {
            let now = Date.now
            let future = Date.distantFuture
            let predicate = #Predicate<TVBuddyMovie> { $0.releaseDate ?? future >= now }
            let tvbMovies = try modelContext.fetch(
                FetchDescriptor<TVBuddyMovie>(predicate: predicate)
            )

            for tvbMovie in tvbMovies {
                guard let movie = await MovieStore.shared.movie(withID: tvbMovie.id) else {
                    continue
                }
                tvbMovie.update(movie: movie)
            }

            MovieActor.logger.info("Updated \(tvbMovies.count) movies")
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }
}
