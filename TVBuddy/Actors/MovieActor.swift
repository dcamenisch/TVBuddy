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

    /// Toggles a movie's presence in the watchlist.
    /// If the movie is in the watchlist, it's removed. If not, it's added (marked as not watched, not favorite).
    func toggleWatchlist(movieID: Movie.ID) async {
        let predicate = #Predicate<TVBuddyMovie> { $0.id == movieID }
        do {
            if (try modelContext.fetch(FetchDescriptor(predicate: predicate)).first) != nil {
                await deleteMovie(id: movieID)
            } else {
                await addMovie(id: movieID, watched: false, isFavorite: false)
            }
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Toggles a movie's watched status.
    /// If the movie doesn't exist locally, it's added and marked according to the toggle.
    func toggleWatched(movieID: Movie.ID) async {
        let predicate = #Predicate<TVBuddyMovie> { $0.id == movieID }
        do {
            if let existingMovie = try modelContext.fetch(FetchDescriptor(predicate: predicate))
                .first
            {
                existingMovie.watched.toggle()
                try modelContext.save()

                MovieActor.logger.info(
                    "Toggled watched status for movie \(existingMovie.title) to \(existingMovie.watched)"
                )
            } else {
                await addMovie(id: movieID, watched: true, isFavorite: false)
            }
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Toggles a movie's favorite status.
    /// If the movie doesn't exist locally, it's added and marked as favorite (and watched, as per previous view logic).
    func toggleFavorite(movieID: Movie.ID) async {
        let predicate = #Predicate<TVBuddyMovie> { $0.id == movieID }
        do {
            if let existingMovie = try modelContext.fetch(FetchDescriptor(predicate: predicate))
                .first
            {
                existingMovie.isFavorite.toggle()
                try modelContext.save()

                MovieActor.logger.info(
                    "Toggled favorite status for movie \(existingMovie.title) to \(existingMovie.isFavorite)"
                )
            } else {
                await addMovie(id: movieID, watched: true, isFavorite: true)
            }
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Inserts a new movie into the database if it doesn't exist
    private func addMovie(
        id: Movie.ID,
        watched: Bool,
        isFavorite: Bool = false,
    ) async {
        do {
            let predicate = #Predicate<TVBuddyMovie> { $0.id == id }
            if (try modelContext.fetch(FetchDescriptor(predicate: predicate)).first) != nil {
                MovieActor.logger.info("Could not add movie with id \(id), since it already exists")
            }

            guard let movie = await MovieStore.shared.movie(withID: id) else {
                MovieActor.logger.warning(
                    "Could not fetch movie details for ID \(id) from MovieStore."
                )
                return
            }

            let newMovie = TVBuddyMovie(movie: movie, watched: watched, isFavorite: isFavorite)
            modelContext.insert(newMovie)
            try modelContext.save()

            MovieActor.logger.info(
                "Inserted movie \(newMovie.title): watched=\(watched), favorite=\(isFavorite)"
            )
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }

    /// Deletes a movie from the database.
    private func deleteMovie(id: Movie.ID) async {
        do {
            let predicate = #Predicate<TVBuddyMovie> { $0.id == id }
            let tvbMovie = try modelContext.fetch(FetchDescriptor(predicate: predicate)).first

            guard let tvbMovie = tvbMovie else {
                MovieActor.logger.warning("Attempted to delete non-existent movie with ID \(id).")
                return
            }

            let title = tvbMovie.title
            modelContext.delete(tvbMovie)
            try modelContext.save()

            MovieActor.logger.info("Deleted movie \(title)")
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

            try modelContext.save()

            MovieActor.logger.info("Updated \(tvbMovies.count) movies")
        } catch {
            MovieActor.logger.error("\(error.localizedDescription)")
        }
    }
}
