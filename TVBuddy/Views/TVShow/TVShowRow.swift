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
    
    @State var poster: URL?
    
    @Query
    private var tvShows: [TVBuddyTVShow]
    
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
                
                Button(action: toggleTVShowInWatchlist) {
                    Image(systemName: buttonImage())
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
        .task(id: tvShow) {
            poster = await TVStore.shared.poster(withID: tvShow.id)
        }
    }
    
    private func toggleTVShowInWatchlist() {
        if let tvShow = tvShows.first {
            context.delete(tvShow)
        } else {
            insertTVShow(tmdbTVShow: tvShow)
        }
    }
    
    private func buttonImage() -> String {
        if let tvShow = tvShows.first {
            return tvShow.finishedWatching ? "eye.circle" : "checkmark.circle"
        } else {
            return "plus.circle"
        }
    }
    
    private func insertTVShow(tmdbTVShow: TVSeries, watched: Bool = false) {
        Task {
            guard let detailedTVShow = await TVStore.shared.show(withID: tmdbTVShow.id) else {
                return
            }
            
            let tvShow = TVBuddyTVShow(
                tvShow: detailedTVShow, startedWatching: watched, finishedWatching: watched
            )
            context.insert(tvShow)
                        
            let tmdbEpisodes = await withTaskGroup(
                of: TVSeason?.self, returning: [TVSeason].self
            ) { group in
                for season in detailedTVShow.seasons ?? [] {
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
                contentsOf: tmdbEpisodes.compactMap { TVBuddyTVEpisode(episode: $0, watched: $0.seasonNumber == 0 ? false : watched) })
        }
    }
}
