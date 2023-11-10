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
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
    let tvSeriesID: TMDb.TVShow.ID
    let tvSeriesSeasonNumber: Int
    let tvSeriesEpisodeNumber: Int
    
    let showOverview: Bool
    
    @Query
    private var episodes: [TVEpisode]
    private var _episode: TVEpisode? { episodes.first }
    
    private var show: TMDb.TVShow? { tvStore.show(withID: tvSeriesID) }
    
    private var episode: TMDb.TVShowEpisode? {
        tvStore.episode(tvSeriesEpisodeNumber, season: tvSeriesSeasonNumber, forTVShow: tvSeriesID)
    }
    private var backdrop: URL? { tvStore.backdrop(withID: tvSeriesID) }
    
    init(tvSeriesID: TMDb.TVShow.ID, tvSeriesSeasonNumber: Int, tvSeriesEpisodeNumber: Int, showOverview: Bool) {
        self.tvSeriesID = tvSeriesID
        self.tvSeriesSeasonNumber = tvSeriesSeasonNumber
        self.tvSeriesEpisodeNumber = tvSeriesEpisodeNumber
        self.showOverview = showOverview
        
        _episodes = Query(filter: #Predicate<TVEpisode> {
            $0.episodeNumber == tvSeriesEpisodeNumber
            && $0.seasonNumber == tvSeriesSeasonNumber
            && $0.tvSeries?.id == tvSeriesID
        })
    }
    
    var body: some View {
        HStack {
            ImageView(title: episode?.name ?? "", url: backdrop)
                .frame(width: 130)
                .aspectRatio(1.77, contentMode: .fit)
                .cornerRadius(5.0)
            
            VStack(alignment: .leading) {
                if showOverview {
                    Text(episode?.name ?? "")
                        .font(.headline)
                        .lineLimit(1)
                        .bold()
                    
                    Text(episode?.overview ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .bold()
                } else {
                    Text(show?.name ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .bold()
                    
                    Text(episode?.name ?? "")
                        .font(.headline)
                        .lineLimit(1)
                        .bold()
                    
                    Text("S\(String(format: "%02d", episode?.seasonNumber ?? 0))E\(String(format: "%02d", episode?.episodeNumber ?? 0))")
                        .font(.subheadline)
                        .lineLimit(1)
                        .bold()
                }
            }
            
            Spacer()
            
            Button(action: {
                _episode?.watched.toggle()
                try? context.save()
            }, label: {
                Image(systemName: _episode?.watched ?? false ? "checkmark.circle" : "plus.circle")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding(8)
            })
        }
    }
}
