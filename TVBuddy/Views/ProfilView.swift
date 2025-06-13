//
//  ProfilView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct ProfilView: View {

    @Query
    private var allMovies: [TVBuddyMovie]

    @Query(filter: #Predicate<TVBuddyMovie> { $0.watched })
    private var watchedMovies: [TVBuddyMovie]

    @Query(filter: #Predicate<TVBuddyTVShow> { $0.finishedWatching })
    private var watchedTVShows: [TVBuddyTVShow]

    @Query(filter: #Predicate<TVBuddyTVShow> { $0.isArchived })
    private var archivedTVShows: [TVBuddyTVShow]

    @Query(filter: #Predicate<TVBuddyTVEpisode> { !($0.tvShow?.isArchived ?? false) })
    private var allTVEpisodes: [TVBuddyTVEpisode]

    @Query(filter: #Predicate<TVBuddyTVEpisode> { $0.watched })
    private var watchedTVEpisodes: [TVBuddyTVEpisode]

    private var watchlistProgress: CGFloat {
        Double(watchedMovies.count + watchedTVEpisodes.count)
            / Double(allMovies.count + allTVEpisodes.count)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                // Watchlist Progress Section
                VStack(spacing: 16) {
                    Text("Watchlist Progress")
                        .font(.title.bold())
                        .foregroundColor(.primary)

                    CircularProgressBar(progress: watchlistProgress, strokeWidth: 20) {
                        VStack {
                            Text("\(String(format: "%.2f", watchlistProgress * 100))%")
                                .font(.largeTitle.bold())

                            Text("of your watchlist completed.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .frame(width: 200, height: 200)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)

                // Stats Section
                HStack {
                    StatCard(title: "Watched TV Shows", value: watchedTVShows.count)
                    StatCard(title: "Watched Episodes", value: watchedTVEpisodes.count)
                }

                StatCard(title: "Watched Movies", value: watchedMovies.count)

                // Media Collections
                VStack {
                    MediaCollection(
                        title: "Watched Movies (\(watchedMovies.count))",
                        media: watchedMovies
                    ).id(watchedMovies)

                    MediaCollection(
                        title: "Watched TV Shows (\(watchedTVShows.count))",
                        media: watchedTVShows
                    ).id(watchedTVShows)

                    MediaCollection(
                        title: "Archived TV Shows (\(archivedTVShows.count))",
                        media: archivedTVShows
                    ).id(archivedTVShows)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Profil")
    }
}

// MARK: - Reusable StatCard View
struct StatCard: View {
    let title: String
    let value: Int

    var body: some View {
        VStack {
            Text("\(value)")
                .font(.largeTitle.bold())

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
