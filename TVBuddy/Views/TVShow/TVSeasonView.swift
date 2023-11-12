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
    
    let id: TMDb.TVShow.ID
    let seasonNumber: Int
    
    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden
    
    @State var tmdbSeason: TMDb.TVShowSeason?
    @State var poster: URL?
    @State var backdrop: URL?
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
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
                    Text(tmdbSeason?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
            }
            .task {
                tmdbSeason = await tvStore.season(seasonNumber, forTVShow: id)
                poster = await tvStore.poster(withID: id)
                backdrop = await tvStore.backdrop(withID: id)
            }
    }
    
    @ViewBuilder private var content: some View {
        if let tmdbSeason = tmdbSeason {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                visibility = offset > 290 ? .visible : .hidden
            } content: {
                TVSeasonHeader(season: tmdbSeason, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
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
                            TVEpisodeRow(
                                tvShowID: id,
                                seasonNumber: episode.seasonNumber,
                                episodeNumber: episode.episodeNumber,
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
