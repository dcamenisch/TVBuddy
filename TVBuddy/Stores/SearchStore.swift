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
    case tvseries = "TV Series"
    case people = "People"

    var id: String { rawValue }
}

class SearchStore: ObservableObject {

    @Published var searchQuery: String = ""
    @Published var results: [TMDb.Media]?
    @Published var isSearching = false
    @Published var searchScope: SearchScope = .all

    private let searchManager: SearchManager

    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    private var newPageTask: Task<Void, Never>?

    init() {
        self.searchManager = SearchManager()
    }

    @MainActor
    func search() async {
        searchTask?.cancel()
        newPageTask?.cancel()

        currentPage = 1

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            results = nil
        } else {
            searchTask = Task {
                isSearching = true
                let newResults = await searchManager.search(query: query)
                if !Task.isCancelled {
                    results = newResults
                    isSearching = false
                }
            }
        }
    }

    @MainActor
    func fetchNextPage(currentMediaItem: TMDb.Media) {
        guard !isSearching else { return }

        guard let res = results else { return }

        let resultIDs = res.map(\.id)
        let index = resultIDs.firstIndex(where: { $0 == currentMediaItem.id })
        let thresholdIndex = resultIDs.endIndex - AppConstants.nextPageOffset

        guard index == thresholdIndex else { return }

        currentPage += 1

        let query = searchQuery.trimmingCharacters(in: .whitespaces)

        newPageTask = Task {
            isSearching = true
            let newPage = await searchManager.search(query: query, page: currentPage)
            if !Task.isCancelled {
                results = (results ?? []) + (newPage ?? [])
                isSearching = false
            }
        }
    }

}
