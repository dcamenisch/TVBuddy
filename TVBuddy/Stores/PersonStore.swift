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
	func person(withID id: TMDb.Person.ID) -> Person? {
        if persons[id] == nil {
            Task {
                let person = await personManager.fetchPerson(withID: id)
                guard let person = person else { return }
                persons[id] = person
            }
        }
        
        return persons[id]
	}
	
    @MainActor
	func image(forPerson id: TMDb.Person.ID) -> URL? {
        if images[id] == nil {
            Task {
                let url = await personManager.fetchImage(withID: id)
                guard let url = url else { return }
                images[id] = url
            }
        }
        
        return images[id]
	}
	
}
