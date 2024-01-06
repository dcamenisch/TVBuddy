//
//  SearchView.swift
//  TVBuddy
//
//  Created by Danny on 24.06.22.
//

import SwiftUI
import TMDb

struct SearchView: View {
    private var searchStore: SearchStore = SearchStore()
    
    @State private var isSearching: Bool = false
    @State private var searchText: String = ""
    @State private var searchResults: [Media] = []
    
    var body: some View {
        let _ = Self._printChanges()
        
        List {
            ForEach(Array(searchResults.enumerated()), id: \.element) { index, element in
                MediaRowItem(mediaItem: element)
                    .task {
                        if searchResults.endIndex - AppConstants.nextPageOffset == index {
                            searchResults = await searchStore.search(searchText)
                        }
                    }
            }
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
        .searchable(text: $searchText)
        //        .searchScopes($searchStore.searchScope) {
        //            ForEach(SearchScope.allCases) { category in
        //                Text(category.rawValue).tag(SearchScope(rawValue: category.rawValue))
        //            }
        //        }
        .scrollIndicators(.never)
        .navigationTitle("Search")
        .task(id: searchText) {
            isSearching = true
            searchResults = await searchStore.search(searchText)
            isSearching = false
        }
    }
    
    @ViewBuilder
    private var overlay: some View {
        if isSearching && searchResults.isEmpty {
            ProgressView()
        } else if searchResults.isEmpty {
            ContentUnavailableView.search(text: searchText)
        }
    }
}
