//
//  PersonStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class PersonStore {
    static let shared = PersonStore()
    
    private let personManager: PersonManager = PersonManager()
    
    private var imageService: ImagesConfiguration? {
        AppConstants.apiConfiguration?.images
    }

    private var persons: [Person.ID: Person] = [:]
    private var images: [Person.ID: PersonImageCollection] = [:]

    @MainActor
    func person(withID id: Person.ID) async -> Person? {
        if persons[id] == nil {
            let person = await personManager.fetchPerson(withID: id)
            guard let person = person else { return nil }

            persons[id] = person
        }

        return persons[id]
    }

    @MainActor
    func images(forPerson id: Person.ID) async -> [URL] {
        if images[id] == nil {
            let imageCollection = await personManager.fetchImages(withID: id)
            guard let imageCollection = imageCollection else { return [] }

            images[id] = imageCollection
        }
        
        return images[id]?.profiles.compactMap { profile in
            imageService?.profileURL(
                for: profile.filePath,
                idealWidth: AppConstants.idealPosterWidth
            )
        } ?? []
    }
}
