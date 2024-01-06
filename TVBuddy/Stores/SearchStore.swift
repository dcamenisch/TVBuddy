//
//  SearchStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

enum SearchScope: String, Codable, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case movies = "Movies"
    case tvShows = "TV Shows"
    case people = "People"

    var id: String { rawValue }
}

class SearchStore: ObservableObject {
//    @Published var searchScope: SearchScope = .all

    private let searchManager: SearchManager = SearchManager()

    private var searchPage = 0
    private var searchQuery = ""
    private var results: [Media] = []

    init() {}

    @MainActor
    func search(_ searchText: String) async -> [Media] {
        let newSearchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery != newSearchQuery {
            results = []
            searchPage = 0
            searchQuery = newSearchQuery
        }

        let nextPageNumber = searchPage + 1
    
        var newPage = await searchManager.search(query: searchQuery, page: nextPageNumber) ?? []
        newPage.removeAll { item in results.contains { $0.id == item.id } }
        results += newPage
        
        searchPage = max(searchPage, nextPageNumber)
        return results
    }
}
