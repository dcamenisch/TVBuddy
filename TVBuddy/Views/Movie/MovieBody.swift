//
//  MovieBody.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI
import TMDb
import WrappingHStack

struct MovieBody: View {
    @Environment(\.modelContext) private var context
    
    @State private var credits: ShowCredits?
    @State private var recommendations: [Movie]?
    
    let movie: Movie
    let tvbMovie: TVBuddyMovie?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            watchButtons
            overview
            genres
            castAndCrew
            similarMovies
        }
        .task {
            credits = await MovieStore.shared.credits(forMovie: movie.id)
            recommendations = await MovieStore.shared.recommendations(forMovie: movie.id)
        }
    }
    
    private var watchButtons: some View {
        HStack {
            Button {
                if let movie = tvbMovie {
                    context.delete(movie)
                } else {
                    context.insert(TVBuddyMovie(movie: movie, watched: false))
                }
            } label: {
                Label("Watchlist", systemImage: tvbMovie == nil ? "plus" : "checkmark")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }
            
            Button {
                if let movie = tvbMovie {
                    movie.watched.toggle()
                } else {
                    context.insert(TVBuddyMovie(movie: movie, watched: true))
                }
            } label: {
                Label("Watched", systemImage: tvbMovie?.watched ?? false ? "eye.fill" : "eye")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }
        }
        .bold()
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder
    private var overview: some View {
        if let overview = movie.overview, !overview.isEmpty {
            Text("Storyline")
                .font(.title2)
                .bold()
            Text(overview)
        }
    }
    
    @ViewBuilder
    private var genres: some View {
        if let genres = movie.genres {
            WrappingHStack(genres) { genre in
                Text(genre.name)
                    .font(.headline)
                    .padding(.horizontal, 10.0)
                    .padding(.vertical, 8.0)
                    .background {
                        RoundedRectangle(cornerRadius: 15.0, style: .circular)
                            .foregroundColor(Color(UIColor.systemGray6))
                    }
            }
        }
    }
    
    @ViewBuilder
    private var castAndCrew: some View {
        if let credits = credits, !credits.cast.isEmpty || !credits.crew.isEmpty {
            Text("Cast & Crew")
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    // Needed for SwiftUI to correctly calculate the height when the first
                    // CreditsItem has a name that only spans one line
                    CreditsItem(id: 0, name: "Lorem ipsum dolor sit amet", role: "-")
                        .hidden()
                    
                    LazyHStack(alignment: .top, spacing: 10) {
                        ForEach(credits.cast) { cast in
                            CreditsItem(
                                id: cast.id,
                                name: cast.name,
                                role: cast.character
                            )
                        }
                                
                        ForEach(credits.crew, id: \.uniqueId) { crew in
                            CreditsItem(
                                id: crew.id,
                                name: crew.name,
                                role: crew.job
                            )
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var similarMovies: some View {
        if let movies = recommendations, !movies.isEmpty {
            MediaCollection(title: "Recommendations", media: movies)
        }
    }
}
