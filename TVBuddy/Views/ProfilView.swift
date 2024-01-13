//
//  ProfilView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct ProfilView: View {
    @Query(filter: #Predicate<TVBuddyTVShow> { $0.isArchived })
    private var archivedTVShows: [TVBuddyTVShow]
    
    @Query(filter: #Predicate<TVBuddyTVShow> { $0.finishedWatching })
    private var watchedTVShows: [TVBuddyTVShow]
    
    @Query(filter: #Predicate<TVBuddyMovie> { $0.watched })
    private var watchedMovies: [TVBuddyMovie]

    var body: some View {        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .center, spacing: 5) {
                        Text("\(watchedMovies.count)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Watched Movies")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background2)
                    .cornerRadius(10)

                    VStack(alignment: .center, spacing: 5) {
                        Text("\(watchedTVShows.count)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Watched TV Shows")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background2)
                    .cornerRadius(10)
                }
                
                HStack(spacing: 10) {
                    CircularProgressBar(progress: 0.5) {
                        Text("S0")
                            .font(.title)
                            .foregroundStyle(Color.foreground2)
                    }
                    
                    Text("This placeholder will later be replace with the percentage of the watchlist that the user completed")
                }
            
    
                
                MediaCollection(title: "Archived TV Shows (\(archivedTVShows.count))", media: archivedTVShows).id(archivedTVShows)
                MediaCollection(title: "Watched TV Shows (\(watchedTVShows.count))", media: watchedTVShows).id(watchedTVShows)
                MediaCollection(title: "Watched Movies (\(watchedMovies.count))", media: watchedMovies).id(watchedMovies)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Profil")
    }
}
