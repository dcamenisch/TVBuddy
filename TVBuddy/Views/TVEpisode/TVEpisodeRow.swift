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
    
    private let tvShowID: TVSeries.ID
    private let tvShowName: String
    
    private let clickable: Bool
    private let showOverview: Bool
    
    private let tvBuddyTVEpisode: TVBuddyTVEpisode?
    
    private var seasonNumber: Int {
        tvEpisode?.seasonNumber ?? tvBuddyTVEpisode?.seasonNumber ?? 0
    }
    
    private var episodeNumber: Int {
        tvEpisode?.episodeNumber ?? tvBuddyTVEpisode?.episodeNumber ?? 0
    }

    @State private var tvEpisode: TVEpisode?
    @State private var backdrop: URL?
    
    init(tvShow: TVSeries, tvEpisode: TVEpisode, tvBuddyTVEpisode: TVBuddyTVEpisode? = nil, clickable: Bool  = false, showOverview: Bool = true) {
        self.tvShowID = tvShow.id
        self.tvShowName = tvShow.name
        
        self._tvEpisode = State(initialValue: tvEpisode)
        self.tvBuddyTVEpisode = tvBuddyTVEpisode
        
        self.clickable = clickable
        self.showOverview = showOverview
    }
    
    init(tvBuddyTVShow: TVBuddyTVShow, tvBuddyTVEpisode: TVBuddyTVEpisode? = nil, clickable: Bool  = false, showOverview: Bool = true) {
        self.tvShowID = tvBuddyTVShow.id
        self.tvShowName = tvBuddyTVShow.name
        
        self.tvBuddyTVEpisode = tvBuddyTVEpisode
        
        self.clickable = clickable
        self.showOverview = showOverview
    }
    
    var body: some View {
        Group {
            if clickable {
                NavigationLink {
                    TVShowView(id: tvShowID)
                } label: {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
        .task {
            tvEpisode = await TVStore.shared.episode(episodeNumber, season: seasonNumber, forTVSeries: tvShowID)
            backdrop = await TVStore.shared.backdrop(withID: tvShowID, season: seasonNumber, episode: episodeNumber)
        }
    }

    var content: some View {
        HStack {
            ImageView(url: backdrop, placeholder: tvEpisode?.name ?? "")
                .frame(width: 130)
                .aspectRatio(1.77, contentMode: .fit)
                .cornerRadius(5.0)
            
            VStack(alignment: .leading) {
                if showOverview {
                    Text(tvEpisode?.name ?? "")
                        .font(.headline)
                        .lineLimit(1)
                        .bold()
                    
                    Text(tvEpisode?.overview ?? "")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .bold()
                } else {
                    Text(tvShowName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .bold()

                    Text(tvEpisode?.name ?? "")
                        .font(.headline)
                        .lineLimit(1)
                        .bold()

                    Text("S\(String(format: "%02d", seasonNumber ))E\(String(format: "%02d", episodeNumber ))")
                        .font(.subheadline)
                        .lineLimit(1)
                        .bold()
                }
            }
            
            Spacer()
            
            if tvEpisode?.airDate ?? Date.now > Date.now {
                VStack {
                    Text("\(Calendar.current.dateComponents([.day], from: Date.now, to: (tvEpisode?.airDate)!).day ?? 0)")
                        .font(.title)
                        .bold()
                    Text("days")
                        .bold()
                }
                .foregroundStyle(.gray)
                .padding(.horizontal, 8)
                
            } else {
                Button(action: {
                    if let episode = tvBuddyTVEpisode {
                        episode.toggleWatched()
                    } else {
                        insertTVShow(id: tvShowID, watched: false, isFavorite: false, episodeID: tvEpisode?.id ?? 0)
                    }
                }, label: {
                    Image(systemName: tvBuddyTVEpisode?.watched ?? false ? "checkmark.circle" : "plus.circle")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(8)
                })
            }
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
