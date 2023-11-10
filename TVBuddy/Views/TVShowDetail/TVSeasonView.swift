//
//  TVSeasonView.swift
//  TVBuddy
//
//  Created by Danny on 01.10.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct TVSeasonView: View {
    
    let seasonNumber: Int
    let tvShowID: TMDb.TVShow.ID
    
    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
    private var season: TMDb.TVShowSeason? { tvStore.season(seasonNumber, forTVShow: tvShowID) }
    private var poster: URL? { tvStore.poster(withID: tvShowID) }
    private var backdrop: URL? { tvStore.backdrop(withID: tvShowID) }
    private var progress: CGFloat { offset / 350.0 }
    
    var body: some View {
        content
            .toolbarBackground(.black)
            .toolbarBackground(visibility, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(season?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
            }
    }
    
    @ViewBuilder private var content: some View {
        if let season = season {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                visibility = offset > 290 ? .visible : .hidden
            } content: {
                TVSeasonHeaderView(season: season, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    if let overview = season.overview, !overview.isEmpty {
                        Text("Storyline")
                            .font(.title2)
                            .bold()
                        Text(overview)
                    }
                    
                    if let episodes = season.episodes {
                        Text("Episodes")
                            .font(.title2)
                            .bold()
                        ForEach(episodes) { episode in
                            TVEpisodeRow(
                                tvSeriesID: tvShowID,
                                tvSeriesSeasonNumber: episode.seasonNumber,
                                tvSeriesEpisodeNumber: episode.episodeNumber,
                                showOverview: true
                            )
                        }
                    }
                    
                }
                .padding(.horizontal)
            }
        } else {
            ProgressView()
        }
    }
}
