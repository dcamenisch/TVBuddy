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
    @EnvironmentObject private var tvStore: TVStore

    let tmdbTVShow: TVSeries
    let tmdbSeason: TVSeason
    
    @State private var show: TVBuddyTVShow?
    @State private var episodes: [TVBuddyTVEpisode] = []
    
    private var watchedAll: Bool {
        episodes.allSatisfy {
            $0.seasonNumber != tmdbSeason.seasonNumber || $0.watched
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                if show != nil {
                    episodes.forEach { episode in
                        episode.toggleWatched()
                    }
                } else {
                    insertTVShow()
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
                    Text(" out of \(episodes.count)")
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
        .task(id: episodes) {
            let id = tmdbTVShow.id
            let seasonNumber = tmdbSeason.seasonNumber
            
            do {
                show = try context.fetch(FetchDescriptor<TVBuddyTVShow>(predicate: #Predicate<TVBuddyTVShow> { $0.id == id })).first
                episodes = try context.fetch(FetchDescriptor<TVBuddyTVEpisode>(predicate: #Predicate<TVBuddyTVEpisode> {$0.tvShow?.id == id && $0.seasonNumber == seasonNumber}))
            } catch {
                print("Error: \(error)")
            }
        }
    }

    private func insertTVShow() {
        let tvShow = TVBuddyTVShow(tvShow: tmdbTVShow)
        context.insert(tvShow)

        Task {
            let tmdbEpisodes = await withTaskGroup(
                of: TVSeason?.self, returning: [TVSeason].self
            ) { group in
                for season in tmdbTVShow.seasons ?? [] {
                    group.addTask {
                        await tvStore.season(season.seasonNumber, forTVSeries: tmdbTVShow.id)
                    }
                }

                var childTaskResults = [TVSeason]()
                for await result in group {
                    if let result = result {
                        childTaskResults.append(result)
                    }
                }

                return childTaskResults
            }.compactMap { season in
                season.episodes
            }.flatMap {
                $0
            }

            tvShow.episodes.append(
                contentsOf: tmdbEpisodes.compactMap { TVBuddyTVEpisode(episode: $0) })

            tvShow.episodes.forEach { episode in
                if episode.seasonNumber == tmdbSeason.seasonNumber {
                    episode.toggleWatched()
                }
            }
        }
    }
}
