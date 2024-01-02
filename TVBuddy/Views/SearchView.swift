//
//  SearchView.swift
//  TVBuddy
//
//  Created by Danny on 24.06.22.
//

import SwiftUI
import TMDb

struct SearchView: View {
    @EnvironmentObject private var searchStore: SearchStore

    private var isSearching: Bool {
        searchStore.isSearching
    }

    private var media: [Media]? {
        searchStore.results
    }

    var body: some View {
        List(media ?? []) { mediaItem in
            MediaRowItem(mediaItem: mediaItem)
                .onAppear { self.mediaItemDidAppear(currentMediaItem: mediaItem) }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 5)
                        .background(.clear)
                        .foregroundColor(Color(UIColor.systemGray6))
                        .padding(
                            EdgeInsets(
                                top: 4,
                                leading: 10,
                                bottom: 4,
                                trailing: 10
                            )
                        )
                )
        }
        .listStyle(.plain)
        .overlay(overlay)
        .searchable(text: $searchStore.searchQuery)
        .searchScopes($searchStore.searchScope) {
            ForEach(SearchScope.allCases) { category in
                Text(category.rawValue).tag(SearchScope(rawValue: category.rawValue))
            }
        }
        .onReceive(searchStore.$searchQuery) { _ in
            Task { await searchStore.search() }
        }
        .navigationTitle("Search")
        .scrollIndicators(.never)
    }

    @ViewBuilder private var overlay: some View {
        if isSearching && (media?.isEmpty ?? true || media == nil) {
            ProgressView()
        } else if media?.isEmpty ?? true {
            ContentUnavailableView.search(text: searchStore.searchQuery)
        }
    }

    private func mediaItemDidAppear(currentMediaItem mediaItem: Media) {
        searchStore.fetchNextPage(currentMediaItem: mediaItem)
    }
}
