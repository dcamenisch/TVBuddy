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
    
    private let personManager: PersonManager

    var persons: [Person.ID: Person] = [:]
    var images: [Person.ID: URL] = [:]

    private init() {
        personManager = PersonManager()
    }

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
    func image(forPerson id: Person.ID) async -> URL? {
        if images[id] == nil {
            let url = await personManager.fetchImage(withID: id)
            guard let url = url else { return nil }

            images[id] = url
        }

        return images[id]
    }
}
