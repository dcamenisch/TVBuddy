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
    
    @Query
    private var episodes: [TVEpisode]
    private var _episode: TVEpisode? { episodes.first }
    
    private var episode: TMDb.TVShowEpisode? {
        tvStore.episode(tvSeriesEpisodeNumber, season: tvSeriesSeasonNumber, forTVShow: tvSeriesID)
    }
    private var backdrop: URL? { tvStore.backdrop(withID: tvSeriesID) }
    
    init(tvSeriesID: TMDb.TVShow.ID, tvSeriesSeasonNumber: Int, tvSeriesEpisodeNumber: Int) {
        self.tvSeriesID = tvSeriesID
        self.tvSeriesSeasonNumber = tvSeriesSeasonNumber
        self.tvSeriesEpisodeNumber = tvSeriesEpisodeNumber
        
        _episodes = Query(filter: #Predicate<TVEpisode> {
            $0.episodeNumber == tvSeriesEpisodeNumber
            && $0.seasonNumber == tvSeriesSeasonNumber
            && $0.tvSeries?.id == tvSeriesID
        })
    }
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        if let tmdbEpisode = episode {
            HStack {
                ImageView(title: tmdbEpisode.name, url: backdrop)
                    .frame(width: 130)
                    .aspectRatio(1.77, contentMode: .fit)
                    .cornerRadius(5.0)
                
                Text(tmdbEpisode.name)
                    .font(.title3)
                    .lineLimit(2)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    _episode?.watched.toggle()
                    try? context.save()
                }, label: {
                    Image(systemName: _episode?.watched ?? false ? "checkmark.circle" : "plus.circle")
                        .font(.title)
                        .bold()
                        .padding(8)
                })
            }
        } else {
            ProgressView()
        }
    }
}
