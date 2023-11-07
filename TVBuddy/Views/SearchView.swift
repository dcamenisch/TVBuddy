//
//  SearchView.swift
//  TVBuddy
//
//  Created by Danny on 24.06.22.
//

import SwiftUI
import TMDb

struct SearchView: View {
	
	@EnvironmentObject private var movieStore: MovieStore
	@EnvironmentObject private var tvStore: TVStore
	@EnvironmentObject private var personStore: PersonStore
	@EnvironmentObject private var searchStore: SearchStore
	
	private var isSearching: Bool {
		searchStore.isSearching
	}
	
	private var media: [TMDb.Media]? {
		searchStore.results
	}
	
	var body: some View {
		List(media ?? []) { mediaItem in
			MediaRow(mediaItem: mediaItem)
                .onAppear { self.mediaItemDidAppear(currentMediaItem: mediaItem) }
                .tag(mediaItem)
		}
		.listStyle(.plain)
		.overlay(overlay)
		.searchable(text: $searchStore.searchQuery)
		.onReceive(searchStore.$searchQuery) { _ in
			Task { await searchStore.search() }
		}
		.navigationTitle("Search")
	}
	
	@ViewBuilder private var overlay: some View {
		if isSearching && (media?.isEmpty ?? true || media == nil) {
			ProgressView()
		}
		
		Group {
			if !isSearching && searchStore.searchQuery.isEmpty {
				Text("Search for Movies, TV Shows and People")
			}
			
			if !isSearching && !searchStore.searchQuery.isEmpty && (media?.isEmpty ?? false) {
				Text("No results found")
			}
		}
		.multilineTextAlignment(.center)
		.foregroundColor(.secondary)
		.padding(.horizontal)
	}
	
	private func mediaItemDidAppear(currentMediaItem mediaItem: Media, offset: Int = 15) {
		searchStore.fetchNextPage(currentMediaItem: mediaItem, offset: offset)
	}
}
