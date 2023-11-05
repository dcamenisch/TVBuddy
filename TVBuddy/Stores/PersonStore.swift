//
//  PersonStore.swift
//  TVBuddy
//
//  Created by Danny on 17.09.23.
//

import Foundation
import TMDb

class PersonStore: ObservableObject {
    
    private let fetchPersonQueue = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchPersonQueue")
    private let fetchImageQueue  = DispatchQueue(label: "\(String(describing: Bundle.main.bundleIdentifier)).fetchImageQueue")
	
    private var pendingFetchPersonTasks: [TMDb.Person.ID: Task<(), Never>]     = [:]
    private var pendingFetchImageTasks: [TMDb.Person.ID: Task<(), Never>] = [:]
    
	private let personManager: PersonManager
	
	@Published var persons: [TMDb.Person.ID: TMDb.Person] = [:]
	@Published var images: [TMDb.Person.ID: URL] = [:]
	
	init() {
		self.personManager = PersonManager()
	}
	
    @MainActor
	func person(withID id: TMDb.Person.ID) -> Person? {
        if let person = persons[id] {
            return person
        }
        
        if pendingFetchPersonTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let person = await personManager.fetchPerson(withID: id)
            if let person = person {
                persons[id] = person
            }
            
            fetchPersonQueue.sync {
                pendingFetchPersonTasks[id] = nil
            }
        }

        fetchPersonQueue.sync {
            pendingFetchPersonTasks[id] = fetchTask
        }

        return nil
	}
	
    @MainActor
	func image(forPerson id: TMDb.Person.ID) -> URL? {
        if let url = images[id] {
            return url
        }
        
        if pendingFetchImageTasks[id] != nil {
            return nil
        }
        
        let fetchTask = Task {
            let url = await personManager.fetchImage(withID: id)
            if let url = url {
                images[id] = url
            }
            
            fetchImageQueue.sync {
                pendingFetchImageTasks[id] = nil
            }
        }

        fetchImageQueue.sync {
            pendingFetchImageTasks[id] = fetchTask
        }

        return nil
	}
	
}
