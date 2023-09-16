//
//  TVEpisodeRow.swift
//  TVBuddy
//
//  Created by Danny on 01.10.2023.
//

import SwiftUI
import TMDb

struct TVEpisodeRow: View {
    @EnvironmentObject private var tvStore: TVStore
    
    let tvSeriesID: TMDb.TVShow.ID
    let tvSeriesSeasonNumber: Int
    let tvSeriesEpisodeNumber: Int
    
    private var tmdbEpisode: TMDb.TVShowEpisode? { tvStore.episode(tvSeriesEpisodeNumber, season: tvSeriesSeasonNumber, forTVShow: tvSeriesID) }
    private var backdrop: URL? { tvStore.backdrop(withID: tvSeriesID) }
    
    var body: some View {
        HStack {
            ImageView(title: tmdbEpisode?.name ?? "", url: backdrop)
                .frame(width: 130)
                .aspectRatio(1.77, contentMode: .fit)
                .cornerRadius(5.0)
            
            Text(tmdbEpisode?.name ?? "")
                .font(.title3)
                .lineLimit(2)
                .bold()
            
            Spacer()
            
            Button(action: {}, label: {
                Image(systemName: "checkmark")
                    .bold()
                    .padding(8)
                    .background {
                        Circle()
                            .stroke(lineWidth: 4.0)
                            .foregroundColor(.secondary)
                    }
            })
        }
    }
}
