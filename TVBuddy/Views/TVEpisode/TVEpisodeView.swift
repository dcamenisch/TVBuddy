//
//  TVEpisodeView.swift
//  TVBuddy
//
//  Created by Danny on 16.06.2024.
//

import SwiftUI
import TMDb

struct TVEpisodeView: View {
    let episodeNumber: Int
    let seasonNumber: Int
    let id: TVSeries.ID
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var offset: CGFloat = 0.0
    @State private var visibility: Visibility = .hidden
    
    @State private var tvSeries: TVSeries?
    @State private var tvEpisode: TVEpisode?
    @State private var backdropUrl: URL?
    
    private var progress: CGFloat { backdropUrl != nil ? (offset - 300) / 20 : (offset - 30) / 20}
    
    var body: some View {
        content
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
                    Text(tvEpisode?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(progress)
                }
            }
            .task {
                tvSeries = await TVStore.shared.show(
                    withID: id
                )
                tvEpisode = await TVStore.shared.episode(
                    episodeNumber,
                    season: seasonNumber,
                    forTVSeries: id
                )
                backdropUrl = await TVStore.shared.stills(
                    episode: episodeNumber,
                    season: seasonNumber,
                    id: id
                ).first
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let tvEpisode = tvEpisode, let tvSeries = tvSeries {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                if backdropUrl == nil {
                    visibility = offset > 0 ? .visible : .hidden
                } else {
                    visibility = offset > 270 ? .visible : .hidden
                }
            } content: {
                TVEpisodeHeader(series: tvSeries, episode: tvEpisode, backdropUrl: backdropUrl)
                    .padding(.bottom, 10)
                TVEpisodeBody(series: tvSeries, episode: tvEpisode)
                    .padding(.horizontal)
                Spacer()
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    TVEpisodeView(episodeNumber: 1, seasonNumber:1, id: 97546)
}
