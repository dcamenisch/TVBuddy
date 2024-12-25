//
//  TVEpisodeProgressView.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI

struct TVEpisodeProgressView: View {
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<TVBuddyTVShow> { $0.startedWatching && !$0.finishedWatching && !$0.isArchived }, sort: \TVBuddyTVShow.name)
    private var tvShows: [TVBuddyTVShow]
    
    @State private var releasedEpisodes: [TVBuddyTVEpisode] = []
    @State private var upcomingEpisodes: [TVBuddyTVEpisode] = []
    
    private var updateView: Bool { releasedEpisodes.allSatisfy { !$0.watched } }

    var body: some View {
        VStack(alignment: .leading) {
            if !releasedEpisodes.isEmpty {
                Text("Continue Watching")
                    .font(.title2)
                    .bold()
                ForEach(releasedEpisodes) { tvEpisode in
                    if let tvShow = tvEpisode.tvShow {
                        TVEpisodeRow(tvBuddyTVShow: tvShow, tvBuddyTVEpisode: tvEpisode, clickable: true, showOverview: false)
                    }
                }
            }
            
            if !upcomingEpisodes.isEmpty {
                Text("Upcoming Episodes")
                    .font(.title2)
                    .bold()
                ForEach(upcomingEpisodes) { tvEpisode in
                    if let tvShow = tvEpisode.tvShow {
                        TVEpisodeRow(tvBuddyTVShow: tvShow, tvBuddyTVEpisode: tvEpisode, clickable: true, showOverview: false)
                    }
                }
            }
        }
        .task(id: updateView) {
            var releasedEpisodes = [TVBuddyTVEpisode]()
            var upcomingEpisodes = [TVBuddyTVEpisode]()
            
            for tvShow in tvShows {
                let id = tvShow.id
                let sortDescriptor = [
                    SortDescriptor(\TVBuddyTVEpisode.seasonNumber),
                    SortDescriptor(\TVBuddyTVEpisode.episodeNumber)
                ]
                                
                let episodesPredicate = #Predicate<TVBuddyTVEpisode> { $0.tvShow?.id == id && $0.seasonNumber > 0 && !$0.watched }
                let episode = try? context.fetch(FetchDescriptor(predicate: episodesPredicate, sortBy: sortDescriptor)).first
                                
                if let episode = episode, let airDate = episode.airDate {
                    if airDate <= Date.now {
                        releasedEpisodes.append(episode)
                    } else {
                        upcomingEpisodes.append(episode)
                    }
                }
            }
            
            upcomingEpisodes.sort { $0.airDate ?? .distantFuture < $1.airDate ?? .distantFuture }
            
            self.releasedEpisodes = releasedEpisodes
            self.upcomingEpisodes = upcomingEpisodes
        }
    }
}
