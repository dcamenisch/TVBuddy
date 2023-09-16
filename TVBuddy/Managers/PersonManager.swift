//
//  PersonManager.swift
//  tvTracker
//
//  Created by Danny on 03.07.22.
//

import Foundation
import TMDb

class PersonManager {
	
	private let tmdb = AppConstants.tmdb
	
	func fetchPerson(withID id: TMDb.Person.ID) async -> TMDb.Person? {
		do {
			return try await tmdb.people.details(forPerson: id)
		} catch {
			return nil
		}
	}
	
	func fetchImage(withID id: TMDb.Person.ID) async -> URL? {
		do {
			let images = try await tmdb.people.images(forPerson: id)
			return try await tmdb
                .configurations
                .apiConfiguration()
                .images
                .profileURL(for: images.profiles.first?.filePath, idealWidth: AppConstants.idealPosterWidth)
		} catch {
			return nil
		}
	}
	
}
