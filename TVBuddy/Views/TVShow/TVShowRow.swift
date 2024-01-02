//
//  TVShowRow.swift
//  TVBuddy
//
//  Created by Danny on 02.01.2024.
//

import SwiftData
import SwiftUI
import TMDb

struct TVShowRow: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
    @State var poster: URL?
    
    @Query
    private var tvShows: [TVBuddyTVShow]
    private var _tvShow: TVBuddyTVShow? { tvShows.first }
    
    private var isOnWatchlist: Bool {
        _tvShow != nil
    }
    
    private var markedAsSeen: Bool {
        guard let tvShow = _tvShow else { return false }
        return tvShow.finishedWatching
    }
    
    let tvShow: TVSeries
    
    init(tvShow: TVSeries) {
        self.tvShow = tvShow
        _tvShows = Query(filter: #Predicate<TVBuddyTVShow> { $0.id == tvShow.id })
    }
    
    var body: some View {
        NavigationLink {
            TVShowView(id: tvShow.id)
        } label: {
            HStack {
                ImageView(title: tvShow.name, url: poster)
                    .posterStyle(size: .tiny)
                
                VStack(alignment: .leading, spacing: 5) {
                    if let releaseDate = tvShow.firstAirDate {
                        Text(DateFormatter.year.string(from: releaseDate))
                            .foregroundColor(.gray)
                    }
                    
                    Text(tvShow.name)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button {
                    if let tvShow = _tvShow {
                        context.delete(tvShow)
                    } else {
                        insertTVShow(tmdbTVShow: tvShow)
                    }
                } label: {
                    Image(systemName: isOnWatchlist ? markedAsSeen ? "eye.circle" : "checkmark.circle" : "plus.circle")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
        .task(id: tvShow) {
            poster = await tvStore.poster(withID: tvShow.id)
        }
    }
    
    private func insertTVShow(tmdbTVShow: TVSeries, watched: Bool = false) {
        let tvShow = TVBuddyTVShow(
            tvShow: tmdbTVShow, startedWatching: watched, finishedWatching: watched
        )
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
                contentsOf: tmdbEpisodes.compactMap { TVBuddyTVEpisode(episode: $0, watched: $0.seasonNumber == 0 ? false : watched) })
        }
    }
}
