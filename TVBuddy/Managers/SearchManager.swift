//
//  SearchManager.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import Foundation
import TMDb

class SearchManager {
    let searchService = SearchService()

    func search(query: String, page: Int = 1) async -> [Media]? {
        do {
            return try await searchService.searchAll(query: query, page: page).results
        } catch {
            return nil
        }
    }
}
