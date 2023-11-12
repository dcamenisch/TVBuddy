//
//  PersonStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class PersonStore: ObservableObject {

    private let personManager: PersonManager

    @Published var persons: [TMDb.Person.ID: TMDb.Person] = [:]
    @Published var images: [TMDb.Person.ID: URL] = [:]

    init() {
        self.personManager = PersonManager()
    }
    
    @MainActor
    func person(withID id: TMDb.Person.ID) async -> Person? {
        if self.persons[id] == nil {
            let person = await personManager.fetchPerson(withID: id)
            guard let person = person else { return nil }
            
            self.persons[id] = person
        }
        
        return self.persons[id]
    }
    
    @MainActor
    func image(forPerson id: TMDb.Person.ID) async -> URL? {
        if self.images[id] == nil {
            let url = await personManager.fetchImage(withID: id)
            guard let url = url else { return nil }
            
            self.images[id] = url
        }
        
        return self.images[id]
    }

}
