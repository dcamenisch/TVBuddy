//
//  TVShowBody.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import Foundation
import SwiftData
import SwiftUI
import TMDb
import WrappingHStack
import NukeUI

struct TVEpisodeBody: View {
    @Environment(\.modelContext) private var context

    let series: TVSeries
    let episode: TVEpisode
    
    @State var urls: [URL] = []

    var body: some View {        
        VStack(alignment: .leading, spacing: 10) {
            watchButtons
            Divider()
            overview
            stills
        }
        .task {
            urls = await TVStore.shared.stills(
                episode: episode.episodeNumber,
                season: episode.seasonNumber,
                id: series.id
            )
        }
    }

    private var watchButtons: some View {
        VStack(alignment: .center) {
            Button {
                // Button action here
            } label: {
//                    Label("Watched", systemImage: tvBuddyTVShow?.finishedWatching ?? false ? "eye.fill" : "eye")
                Label("Watched", systemImage: "eye")
                    .padding(.vertical, 5)
                    .frame(width: UIScreen.main.bounds.width * 2 / 3)
            }
            .bold()
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
    }

    private var overview: some View {
        Group {
            if let overview = episode.overview, !overview.isEmpty {
                Text("S\(episode.seasonNumber), E\(episode.episodeNumber ):")
                    .bold()
                + Text(" ")
                + Text(overview)
            }
        }
    }
    
    private var stills: some View {
        Group {
            if !urls.isEmpty {
                Text("Stills")
                    .font(.title2)
                    .bold()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(urls, id: \.self) { url in
                            LazyImage(url: url) { state in
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Rectangle()
                                        .overlay(ProgressView())
                                        .foregroundStyle(Color.background3)
                                }
                            }
                            .frame(height: 150)
                            .aspectRatio(16 / 9, contentMode: .fill)
                            .cornerRadius(15)
                            .padding(5)
                        }
                    }
                }
            }
        }
    }
}
