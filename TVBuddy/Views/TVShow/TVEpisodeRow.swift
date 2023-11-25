//
//  TVEpisodeRow.swift
//  TVBuddy
//
//  Created by Danny on 01.10.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct TVEpisodeRowNonClickable: View {
    let tvShow: TVSeries
    let tvEpisode: TVEpisode

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore

    @State var backdrop: URL?

    @Query
    private var episodes: [TVBuddyTVEpisode]
    private var episode: TVBuddyTVEpisode? { episodes.first }
    
    init(tvShow: TVSeries, tvEpisode: TVEpisode) {
        self.tvShow = tvShow
        self.tvEpisode = tvEpisode
        
        let id = tvShow.id
        let seasonNumber = tvEpisode.seasonNumber
        let episodeNumber = tvEpisode.episodeNumber
        
        _episodes = Query(filter: #Predicate<TVBuddyTVEpisode> {
            $0.episodeNumber == episodeNumber
                && $0.seasonNumber == seasonNumber
                && $0.tvShow?.id == id
        })
    }
    
    var body: some View {
        HStack {
            ImageView(title: tvEpisode.name , url: backdrop)
                .frame(width: 130)
                .aspectRatio(1.77, contentMode: .fit)
                .cornerRadius(5.0)

            VStack(alignment: .leading) {
                Text(tvEpisode.name )
                    .font(.headline)
                    .lineLimit(1)
                    .bold()

                Text(tvEpisode.overview ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .bold()
            }

            Spacer()

            Button(action: {
                if let episode = episode {
                    episode.toggleWatched()
                } else {
                    insertTVShowWithEpisode(tmdbTVShow: tvShow, tmdbEpisode: tvEpisode, watched: false)
                }
            }, label: {
                Image(systemName: episode?.watched ?? false ? "checkmark.circle" : "plus.circle")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding(8)
            })
        }
        .task {
            backdrop = await tvStore.backdrop(withID: tvShow.id, season: tvEpisode.seasonNumber, episode: tvEpisode.episodeNumber)
        }
    }
    
    private func insertTVShowWithEpisode(
        tmdbTVShow: TVSeries, tmdbEpisode: TVEpisode, watched: Bool = false
    ) {
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
                contentsOf: tmdbEpisodes.compactMap { TVBuddyTVEpisode(episode: $0, watched: watched) })
            tvShow.episodes.first { $0.id == tmdbEpisode.id }?.toggleWatched()
        }
    }
}

struct TVEpisodeRowClickable: View {
    let tvBuddyTVShow: TVBuddyTVShow
    let tvBuddyTVEpisode: TVBuddyTVEpisode

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
    @State var backdrop: URL?
    @State var tvEpisode: TVEpisode?
    
    init(tvBuddyTVShow: TVBuddyTVShow, tvBuddyTVEpisode: TVBuddyTVEpisode) {
        self.tvBuddyTVShow = tvBuddyTVShow
        self.tvBuddyTVEpisode = tvBuddyTVEpisode
    }

    var body: some View {
        NavigationLink {
            TVShowView(id: tvBuddyTVShow.id)
        } label: {
            label
        }
        .buttonStyle(.plain)
        .task(id: tvBuddyTVEpisode) {
            backdrop = await tvStore.backdrop(withID: tvBuddyTVShow.id, season: tvBuddyTVEpisode.seasonNumber, episode: tvBuddyTVEpisode.episodeNumber)
            tvEpisode = await tvStore.episode(tvBuddyTVEpisode.episodeNumber, season: tvBuddyTVEpisode.seasonNumber, forTVSeries: tvBuddyTVShow.id)
        }
    }

    var label: some View {
        HStack {
            ImageView(title: "", url: backdrop)
                .frame(width: 130)
                .aspectRatio(1.77, contentMode: .fit)
                .cornerRadius(5.0)

            VStack(alignment: .leading) {
                Text(tvBuddyTVShow.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .bold()

                Text(tvEpisode?.name ?? "")
                    .font(.headline)
                    .lineLimit(1)
                    .bold()

                Text("S\(String(format: "%02d", tvBuddyTVEpisode.seasonNumber ))E\(String(format: "%02d", tvBuddyTVEpisode.episodeNumber ))")
                    .font(.subheadline)
                    .lineLimit(1)
                    .bold()
            }

            Spacer()

            Button(action: {
                tvBuddyTVEpisode.toggleWatched()
            }, label: {
                Image(systemName: tvBuddyTVEpisode.watched ? "checkmark.circle" : "plus.circle")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding(8)
            })
        }
    }
}
