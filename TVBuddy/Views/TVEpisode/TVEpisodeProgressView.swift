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
    
    @Query(filter: #Predicate<TVBuddyTVShow> { $0.startedWatching && !$0.finishedWatching && !$0.isArchived })
    private var tvShows: [TVBuddyTVShow]
    
    @State private var releasedEpisodes: [TVBuddyTVEpisode] = []
    @State private var upcomingEpisodes: [TVBuddyTVEpisode] = []
    
    private var updateView: Bool { releasedEpisodes.allSatisfy({ !$0.watched }) }

    var body: some View {
        VStack(alignment: .leading) {
            if !releasedEpisodes.isEmpty {
                Text("TV Show Progress")
                    .font(.title2)
                    .bold()
                ForEach(releasedEpisodes) { tvEpisode in
                    if let tvShow = tvEpisode.tvShow {
                        TVEpisodeRowClickable(
                            tvBuddyTVShow: tvShow,
                            tvBuddyTVEpisode: tvEpisode
                        )
                    }
                }
            }
            
            if !upcomingEpisodes.isEmpty {
                Text("Upcoming Episodes")
                    .font(.title2)
                    .bold()
                ForEach(upcomingEpisodes) { tvEpisode in
                    if let tvShow = tvEpisode.tvShow {
                        TVEpisodeRowClickable(
                            tvBuddyTVShow: tvShow,
                            tvBuddyTVEpisode: tvEpisode
                        )
                    }
                }
            }
        }
        .task(id: updateView) {
            let now = Date.now
            let future = Date.distantFuture
            
            var releasedEpisodes = [TVBuddyTVEpisode]()
            var upcomingEpisodes = [TVBuddyTVEpisode]()
            
            tvShows.forEach { tvShow in
                let id = tvShow.id
                let sortDescriptor = [SortDescriptor(\TVBuddyTVEpisode.seasonNumber), SortDescriptor(\TVBuddyTVEpisode.episodeNumber)]
                
                let releasedEpisodesPredicate = #Predicate<TVBuddyTVEpisode> { $0.tvShow?.id == id && $0.seasonNumber > 0 && !$0.watched && $0.airDate ?? future <= now }
                let releasedEpisode = try? context.fetch(FetchDescriptor(predicate: releasedEpisodesPredicate, sortBy: sortDescriptor)).first
                
                if let releasedEpisode = releasedEpisode {
                    releasedEpisodes.append(releasedEpisode)
                    return
                }
                
                let upcomingEpisodesPredicate = #Predicate<TVBuddyTVEpisode> { $0.tvShow?.id == id && $0.seasonNumber > 0 && !$0.watched && $0.airDate ?? future >= now }
                let upcomingEpisode = try? context.fetch(FetchDescriptor(predicate: upcomingEpisodesPredicate, sortBy: sortDescriptor)).first
                
                if let upcomingEpisode = upcomingEpisode {
                    upcomingEpisodes.append(upcomingEpisode)
                }
            }
            
            self.releasedEpisodes = releasedEpisodes
            self.upcomingEpisodes = upcomingEpisodes
        }
    }
}
