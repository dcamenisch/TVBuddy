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
    @State private var viewModel: ViewModel
    
    @Environment(\.modelContext) private var context
        
    @Query
    private var tvShows: [TVBuddyTVShow]
    
    let id: TVSeries.ID
    
    init(id: TVSeries.ID) {
        self.id = id
        _tvShows = Query(filter: #Predicate<TVBuddyTVShow> { $0.id == id })
        
        let viewModel = ViewModel(forTVSeries: id)
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        if let tvSeries = viewModel.tvShow {
            NavigationLink {
                tvSeries.detailView
            } label: {
                HStack {
                    ImageView(url: viewModel.posterURL, placeholder: tvSeries.name)
                        .posterStyle(size: .tiny)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        if let releaseDate = tvSeries.firstAirDate {
                            Text(DateFormatter.year.string(from: releaseDate))
                                .foregroundColor(.gray)
                        }
                        
                        Text(tvSeries.name)
                            .font(.system(size: 22, weight: .bold))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button {
                        let container = context.container
                        let actor = TVShowActor(modelContainer: container)
                        Task {
                            await actor.toggleShowWatchlist(showID: id)
                        }
                    } label: {
                        Image(systemName: buttonImage())
                            .font(.title)
                            .bold()
                            .foregroundStyle(.gray)
                            .padding(8)
                    }
                }
            }
            .buttonStyle(.plain)
        } else {
            ProgressView()
        }
    }
    
    private func buttonImage() -> String {
        if let tvShow = tvShows.first {
            return tvShow.finishedWatching ? "eye.circle" : "checkmark.circle"
        } else {
            return "plus.circle"
        }
    }
}

extension TVShowRow {
    @MainActor @Observable
    class ViewModel {
        let id: TVSeries.ID
        
        private(set) var tvShow: TVSeries?
        private(set) var posterURL: URL?
        
        init(forTVSeries id: TVSeries.ID) {
            self.id = id
            fetchData()
        }
        
        func fetchData() {
            Task {
                tvShow = try? await TVStore.shared.show(withID: id)
                posterURL = await tvShow?.getPosterURL()
            }
        }
    }
}
