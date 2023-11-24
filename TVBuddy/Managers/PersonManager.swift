//
//  PersonManager.swift
//  TVBuddy
//
//  Created by Danny on 03.07.22.
//

import Foundation
import TMDb

class PersonManager {
    private let personService = PersonService()

    private var imageService: ImagesConfiguration? {
        AppConstants.apiConfiguration?.images
    }

    func fetchPerson(withID id: Person.ID) async -> Person? {
        do {
            return try await personService.details(forPerson: id)
        } catch {
            return nil
        }
    }

    func fetchImage(withID id: Person.ID) async -> URL? {
        do {
            let images = try await personService.images(forPerson: id)
            return imageService?.profileURL(
                for: images.profiles.first?.filePath,
                idealWidth: AppConstants.idealPosterWidth
            )
        } catch {
            return nil
        }
    }
}
