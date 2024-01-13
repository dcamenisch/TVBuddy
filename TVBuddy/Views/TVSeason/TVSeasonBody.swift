//
//  TVSeasonBody.swift
//  TVBuddy
//
//  Created by Danny on 12.11.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct TVSeasonBody: View {
    @Environment(\.modelContext) private var context

    let tmdbTVShow: TVSeries
    let tmdbSeason: TVSeason
    let tvBuddyTVShow: TVBuddyTVShow?
    
    @State private var episodes: [TVBuddyTVEpisode] = []
    
    private var watchedAll: Bool {
        episodes.allSatisfy {
            $0.seasonNumber != tmdbSeason.seasonNumber || $0.watched
        } && episodes.count > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                if let tvBuddyTVShow = tvBuddyTVShow {
                    let newValue = !watchedAll
                    episodes.forEach { episode in
                        episode.watched = newValue
                    }
                    tvBuddyTVShow.checkWatching()
                } else {
                    insertTVShow(id: tmdbTVShow.id, watched: false, isFavorite: false)
                }
            } label: {
                Label(watchedAll ? "Mark as unseen" : "Mark as seen", systemImage: watchedAll ? "eye.fill" : "eye")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }
            .bold()
            .buttonStyle(.bordered)

            if let overview = tmdbSeason.overview, !overview.isEmpty {
                Text("Storyline")
                    .font(.title2)
                    .bold()
                Text(overview)
            }

            if let tmdbEpisodes = tmdbSeason.episodes {
                Group {
                    Text("Episodes")
                        .font(.title2)
                        .bold() +
                    Text(" - seen")
                        .font(.subheadline)
                        .bold() +
                    Text(" \(episodes.filter { $0.watched }.count)")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .bold() +
                    Text(" out of \(tmdbEpisodes.count)")
                        .font(.subheadline)
                        .bold()
                }
                
                ForEach(tmdbEpisodes) { episode in
                    TVEpisodeRowNonClickable(
                        tvShow: tmdbTVShow,
                        tvEpisode: episode,
                        tvBuddyTVEpisode: episodes.first(where: {$0.id == episode.id})
                    )
                }
            }
        }
        .task(id: tvBuddyTVShow?.episodes) {
            // This task is triggered a first time when the show gets inserted (without episodes)
            // and a second time when the episodes are added
            
            let id = tmdbTVShow.id
            let seasonNumber = tmdbSeason.seasonNumber
            
            do {
                episodes = try context.fetch(FetchDescriptor<TVBuddyTVEpisode>(predicate: #Predicate<TVBuddyTVEpisode> {$0.tvShow?.id == id && $0.seasonNumber == seasonNumber}))
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func insertTVShow(id: TVSeries.ID, watched: Bool, isFavorite: Bool) {
        Task {
            let container = context.container
            let actor = TVShowActor(modelContainer: container)
            await actor.insertTVShow(id: id, watched: watched, isFavorite: isFavorite)
        }
    }
}
