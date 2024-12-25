//
//  TVEpisodeView.swift
//  TVBuddy
//
//  Created by Danny on 16.06.2024.
//

import SwiftUI
import SwiftData
import TMDb

struct TVEpisodeView: View {
    @State private var viewModel: ViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var offset: CGFloat = 0.0
    @State private var visibility: Visibility = .hidden
    
    private var progress: CGFloat { viewModel.stillURL != nil ? (offset - 300) / 20 : (offset - 30) / 20}
    
    init(episodeNumber: Int, seasonNumber: Int, id: TVSeries.ID) {
        let viewModel = ViewModel(seriesID: id, seasonNumber: seasonNumber, episodeNumber: episodeNumber)
        _viewModel = State(initialValue: viewModel)
    }
    
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
                    Text(viewModel.episode?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(progress)
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if let episode = viewModel.episode, let series = viewModel.series {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                if viewModel.stillURL == nil {
                    visibility = offset > 0 ? .visible : .hidden
                } else {
                    visibility = offset > 270 ? .visible : .hidden
                }
            } content: {
                TVEpisodeHeader(series: series, episode: episode, backdropUrl: viewModel.stillURL)
                    .padding(.bottom, 10)
                TVEpisodeBody(series: series, episode: episode)
                    .padding(.horizontal)
                Spacer()
            }
        } else {
            ProgressView()
        }
    }
}

//
// MARK: ViewModel
//

extension TVEpisodeView {
    @MainActor @Observable
    class ViewModel {
        let seriesID: TVSeries.ID
        let seasonNumber: Int
        let episodeNumber: Int
        
        private(set) var series: TVSeries?
        private(set) var episode: TVEpisode?
        private(set) var stillURL: URL?
        
        init(seriesID: TVSeries.ID, seasonNumber: Int, episodeNumber: Int) {
            self.seriesID = seriesID
            self.seasonNumber = seasonNumber
            self.episodeNumber = episodeNumber
            fetchData()
        }
        
        func fetchData() {
            Task {
                series = try? await TVStore.shared.show(withID: seriesID)
                episode = try? await TVStore.shared.episode(
                    episodeNumber,
                    season: seasonNumber,
                    forTVSeries: seriesID
                )
                stillURL = await TVStore.shared.stills(
                    episode: episodeNumber,
                    season: seasonNumber,
                    id: seriesID
                ).first
            }
        }
    }
}

#Preview {
    TVEpisodeView(episodeNumber: 1, seasonNumber:1, id: 97546)
}
