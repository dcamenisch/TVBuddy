//
//  SearchManager.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import os
import Foundation
import TMDb

class SearchManager {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SearchManager.self)
    )
    
    let searchService = SearchService()

    func search(query: String, page: Int = 1) async -> [Media]? {
        do {
            return try await searchService.searchAll(query: query, page: page).results
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func handleError(_ error: any Error) {
        if let tmdbError = error as? TMDbError, case .network(let networkError) = tmdbError {
            if let nsError = networkError as NSError?, nsError.code == NSURLErrorCancelled {
                SearchManager.logger.info("Request cancelled")
                return
            }
        }
        
        SearchManager.logger.error("\(error.localizedDescription)")
        return
    }
}
