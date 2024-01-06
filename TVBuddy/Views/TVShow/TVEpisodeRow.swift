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
    let tvBuddyTVEpisode: TVBuddyTVEpisode?

    @Environment(\.modelContext) private var context

    @State var backdrop: URL?
    
    var body: some View {
        HStack {
            ImageView(url: backdrop, placeholder: tvEpisode.name)
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
                if let episode = tvBuddyTVEpisode {
                    episode.toggleWatched()
                } else {
                    insertTVShow(id: tvShow.id, watched: false, isFavorite: false, episodeID: tvEpisode.id)
                }
            }, label: {
                Image(systemName: tvBuddyTVEpisode?.watched ?? false ? "checkmark.circle" : "plus.circle")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding(8)
            })
        }
        .task {
            backdrop = await TVStore.shared.backdrop(withID: tvShow.id, season: tvEpisode.seasonNumber, episode: tvEpisode.episodeNumber)
        }
    }
    
    func insertTVShow(id: TVSeries.ID, watched: Bool, isFavorite: Bool, episodeID: TVEpisode.ID) {
        Task {
            let container = context.container
            let actor = TVShowActor(modelContainer: container)
            await actor.insertTVShow(id: id, watched: watched, isFavorite: isFavorite, episodeID: episodeID)
        }
    }
}

struct TVEpisodeRowClickable: View {
    let tvBuddyTVShow: TVBuddyTVShow
    let tvBuddyTVEpisode: TVBuddyTVEpisode
    
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
            backdrop = await TVStore.shared.backdrop(withID: tvBuddyTVShow.id, season: tvBuddyTVEpisode.seasonNumber, episode: tvBuddyTVEpisode.episodeNumber)
            tvEpisode = await TVStore.shared.episode(tvBuddyTVEpisode.episodeNumber, season: tvBuddyTVEpisode.seasonNumber, forTVSeries: tvBuddyTVShow.id)
        }
    }

    var label: some View {
        HStack {
            ImageView(url: backdrop)
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
