//
//  TVShowRow.swift
//  TVBuddy
//
//  Created by Danny on 02.01.2024.
//

import SwiftData
import SwiftUI
import TMDb

struct TVShowRow: View {
    @Environment(\.modelContext) private var context
    
    @State var url: URL?
    
    @Query
    private var tvShows: [TVBuddyTVShow]
    
    let tvShow: TVSeries
    
    init(tvShow: TVSeries) {
        self.tvShow = tvShow
        _tvShows = Query(filter: #Predicate<TVBuddyTVShow> { $0.id == tvShow.id })
    }
    
    var body: some View {
        NavigationLink {
            tvShow.detailView
        } label: {
            HStack {
                ImageView(url: url, placeholder: tvShow.name)
                    .posterStyle(size: .tiny)
                
                VStack(alignment: .leading, spacing: 5) {
                    if let releaseDate = tvShow.firstAirDate {
                        Text(DateFormatter.year.string(from: releaseDate))
                            .foregroundColor(.gray)
                    }
                    
                    Text(tvShow.name)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: toggleTVShowInWatchlist) {
                    Image(systemName: buttonImage())
                        .font(.title)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
        .task(id: tvShow) {
            url = await TVStore.shared.posters(id: tvShow.id).first
        }
    }
    
    private func toggleTVShowInWatchlist() {
        if let tvShow = tvShows.first {
            context.delete(tvShow)
            try? context.save()
        } else {
            insertTVShow(id: tvShow.id, watched: false, isFavorite: false)
        }
    }
    
    private func buttonImage() -> String {
        if let tvShow = tvShows.first {
            return tvShow.finishedWatching ? "eye.circle" : "checkmark.circle"
        } else {
            return "plus.circle"
        }
    }
    
    func insertTVShow(id: TVSeries.ID, watched: Bool, isFavorite: Bool) {
        Task {
            let container = context.container
            let actor = TVShowActor(modelContainer: container)
            await actor.insertTVSeries(id: id, watched: watched, isFavorite: isFavorite)
        }
    }
}
