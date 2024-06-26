//
//  PersonManager.swift
//  TVBuddy
//
//  Created by Danny on 03.07.22.
//

import os
import Foundation
import TMDb

class PersonManager {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PersonManager.self)
    )
    
    private let personService = AppConstants.tmdbClient.people

    private var imageService: ImagesConfiguration? {
        AppConstants.apiConfiguration?.images
    }

    func fetchPerson(withID id: Person.ID) async -> Person? {
        do {
            return try await personService.details(forPerson: id)
        } catch {
            handleError(error)
            return nil
        }
    }

    func fetchImages(withID id: Person.ID) async -> PersonImageCollection? {
        do {
            return try await personService.images(forPerson: id)
        } catch {
            handleError(error)
            return nil
        }
    }
    
    func handleError(_ error: any Error) {
        if let tmdbError = error as? TMDbError, case .network(let networkError) = tmdbError {
            if let nsError = networkError as NSError?, nsError.code == NSURLErrorCancelled {
                PersonManager.logger.info("Request cancelled")
                return
            }
        }
        
        PersonManager.logger.error("\(error.localizedDescription)")
        return
    }
}
