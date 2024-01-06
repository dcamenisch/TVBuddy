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
        } catch TMDbError.network(let error) {
            if let error = error as NSError?, error.code == NSURLErrorCancelled {
                SearchManager.logger.info("Search request cancelled")
                return nil
            }
            
            SearchManager.logger.error("\(error.localizedDescription)")
            return nil
        } catch {
            SearchManager.logger.error("\(error.localizedDescription)")
            return nil
        }
    }
}
