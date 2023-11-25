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

    let id: TVSeries.ID
    let tmdbSeason: TVSeason
    let tmdbTVShow: TVSeries

    @Query
    private var shows: [TVBuddyTVShow]
    private var _show: TVBuddyTVShow? { shows.first }

    @State private var watchedAll: Bool = false

    init(tmdbTVShow: TVSeries, tmdbSeason: TVSeason) {
        id = tmdbTVShow.id
        self.tmdbTVShow = tmdbTVShow
        self.tmdbSeason = tmdbSeason
        _shows = Query(filter: #Predicate<TVBuddyTVShow> { $0.id == id })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                if let show = _show {
                    show.episodes.forEach { episode in
                        if episode.seasonNumber == tmdbSeason.seasonNumber {
                            episode.toggleWatched()
                        }
                    }
                } else {
                    insertTVShow()
                }

                watchedAll = self._show?.episodes.allSatisfy {
                    $0.seasonNumber != tmdbSeason.seasonNumber || $0.watched
                } ?? false
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

            if let episodes = tmdbSeason.episodes {
                Text("Episodes")
                    .font(.title2)
                    .bold()
                ForEach(episodes) { episode in
                    TVEpisodeRowNonClickable(
                        tvShow: tmdbTVShow,
                        tvEpisode: episode
                    )
                }
            }
        }
        .onAppear(perform: {
            watchedAll = self._show?.episodes.allSatisfy {
                $0.seasonNumber != tmdbSeason.seasonNumber || $0.watched
            } ?? false
        })
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
