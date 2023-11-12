//
//  TVEpisodeRow.swift
//  TVBuddy
//
//  Created by Danny on 01.10.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct TVEpisodeRow: View {
    
    let id: TMDb.TVShow.ID
    let seasonNumber: Int
    let episodeNumber: Int
    let showOverview: Bool
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
    @State var tmdbTVShow: TMDb.TVShow?
    @State var tmdbEpisode: TMDb.TVShowEpisode?
    @State var backdrop: URL?
        
    @Query
    private var episodes: [TVEpisode]
    private var episode: TVEpisode? { episodes.first }
    
    init(tvShowID: TMDb.TVShow.ID, seasonNumber: Int, episodeNumber: Int, showOverview: Bool) {
        self.id = tvShowID
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.showOverview = showOverview
                
        _episodes = Query(filter: #Predicate<TVEpisode> {
            $0.episodeNumber == episodeNumber
            && $0.seasonNumber == seasonNumber
            && $0.tvShow?.id == tvShowID
        })
    }
    
    var body: some View {
        NavigationLink {
            TVSeasonView(id: id, seasonNumber: seasonNumber)
//            TVShowView(id: id)
        } label: {
            HStack {
                ImageView(title: tmdbEpisode?.name ?? "", url: backdrop)
                    .frame(width: 130)
                    .aspectRatio(1.77, contentMode: .fit)
                    .cornerRadius(5.0)
                
                VStack(alignment: .leading) {
                    if showOverview {
                        Text(tmdbEpisode?.name ?? "")
                            .font(.headline)
                            .lineLimit(1)
                            .bold()
                        
                        Text(tmdbEpisode?.overview ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .bold()
                    } else {
                        Text(tmdbTVShow?.name ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .bold()
                        
                        Text(tmdbEpisode?.name ?? "")
                            .font(.headline)
                            .lineLimit(1)
                            .bold()
                        
                        Text("S\(String(format: "%02d", tmdbEpisode?.seasonNumber ?? 0))E\(String(format: "%02d", tmdbEpisode?.episodeNumber ?? 0))")
                            .font(.subheadline)
                            .lineLimit(1)
                            .bold()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if let episode = episode {
                        episode.toggleWatched()
                    } else {
                        insertTVShowWithEpisode(tmdbTVShow: tmdbTVShow!, tmdbEpisode: tmdbEpisode!, watched: false)
                    }
                }, label: {
                    Image(systemName: episode?.watched ?? false ? "checkmark.circle" : "plus.circle")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(8)
                })
            }
        }
        .buttonStyle(.plain)
        .task(id: episode) {
            tmdbTVShow = await tvStore.show(withID: id)
            tmdbEpisode = await tvStore.episode(episodeNumber, season: seasonNumber, forTVShow: id)
            backdrop = await tvStore.backdrop(withID: id)
        }
    }
    
    private func insertTVShowWithEpisode(
        tmdbTVShow: TMDb.TVShow, tmdbEpisode: TMDb.TVShowEpisode, watched: Bool = false
    ) {
        let tvShow: TVShow = TVShow(
            tvShow: tmdbTVShow, startedWatching: watched, finishedWatching: watched)
        context.insert(tvShow)

        Task {
            let tmdbEpisodes = await withTaskGroup(
                of: TMDb.TVShowSeason?.self, returning: [TMDb.TVShowSeason].self
            ) { group in
                for season in tmdbTVShow.seasons ?? [] {
                    group.addTask {
                        await tvStore.season(season.seasonNumber, forTVShow: tmdbTVShow.id)
                    }
                }

                var childTaskResults = [TMDb.TVShowSeason]()
                for await result in group {
                    if let result = result {
                        childTaskResults.append(result)
                    }
                }

                return childTaskResults
            }.compactMap({ season in
                season.episodes
            }).flatMap({
                $0
            })

            tvShow.episodes.append(
                contentsOf: tmdbEpisodes.compactMap { TVEpisode(episode: $0, watched: watched) })
            tvShow.episodes.first { $0.id == tmdbEpisode.id }?.toggleWatched()
        }
    }

}
