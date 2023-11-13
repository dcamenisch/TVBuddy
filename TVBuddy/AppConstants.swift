//
//  AppConstants.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import Foundation
import TMDb

enum AppConstants {
    static let languageCode = "en"
    static let idealPosterWidth = 100
    static let idealBackdropWidth = 400
    static let nextPageOffset = 10
    static let topLimit = 10

    static var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "TMDB-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'TMDB-Info.plist'.")
        }

        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'TMDB-Info.plist'.")
        }
        return value
    }

    static let configurationService = ConfigurationService()
    static var apiConfiguration: APIConfiguration?

    static let discoverService = DiscoverService()
    static let trendingService = TrendingService()
}
