//
//  SearchManager.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import Foundation
import TMDb

class SearchManager {

    private let tmdb = AppConstants.tmdb

    func search(query: String, page: Int = 1) async -> [TMDb.Media]? {
        do {
            return try await tmdb.search.searchAll(query: query, page: page).results
        } catch {
            return nil
        }
    }

}
