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
    
    @Query
    private var shows: [TVBuddyTVShow]
    private var show: TVBuddyTVShow? { shows.first }
    
    @State private var episodes: [TVBuddyTVEpisode] = []
    
    private var watchedAll: Bool {
        episodes.allSatisfy {
            $0.seasonNumber != tmdbSeason.seasonNumber || $0.watched
        } && episodes.count > 0
    }
    
    init(tmdbTVShow: TVSeries, tmdbSeason: TVSeason) {
        self.tmdbTVShow = tmdbTVShow
        self.tmdbSeason = tmdbSeason
        _shows = Query(filter: #Predicate<TVBuddyTVShow> { $0.id == tmdbTVShow.id })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                if show != nil {
                    let newValue = !watchedAll
                    episodes.forEach { episode in
                        episode.watched = newValue
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
        .task(id: show?.episodes) {
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

    private func insertTVShow() {
        let tvShow = TVBuddyTVShow(tvShow: tmdbTVShow)
        context.insert(tvShow)

        Task {
            let tmdbEpisodes = await withTaskGroup(
                of: TVSeason?.self, returning: [TVSeason].self
            ) { group in
                for season in tmdbTVShow.seasons ?? [] {
                    group.addTask {
                        await TVStore.shared.season(season.seasonNumber, forTVSeries: tmdbTVShow.id)
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
