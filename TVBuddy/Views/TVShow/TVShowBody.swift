//
//  TVShowBody.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import Foundation
import SwiftData
import SwiftUI
import TMDb
import WrappingHStack

struct TVShowBody: View {
    @Environment(\.modelContext) private var context

    @State var credits: TVSeriesAggregateCredits?
    @State var recommendations: [TVSeries]?

    let tmdbTVShow: TVSeries
    let tvBuddyTVShow: TVBuddyTVShow?

    private var hasSpecials: Bool {
        return tmdbTVShow.seasons?.count != tmdbTVShow.numberOfSeasons
    }
    
    init(tmdbTVShow: TVSeries, tvBuddyTVShow: TVBuddyTVShow?) {
        self.tmdbTVShow = tmdbTVShow
        self.tvBuddyTVShow = tvBuddyTVShow
    }

    var body: some View {        
        VStack(alignment: .leading, spacing: 10) {
            watchButtons
            overview
            genres
            seasons
            castAndCrew
            similarTVShows
        }
        .task {
            credits = await TVStore.shared.aggregateCredits(forTVSeries: tmdbTVShow.id)
            recommendations = await TVStore.shared.recommendations(forTVSeries: tmdbTVShow.id)
        }
    }

    private var watchButtons: some View {
        let container = context.container
        let actor = TVShowActor(modelContainer: container)

        return HStack {
            Button {
                Task {
                    await actor.toggleShowWatchlist(showID: tmdbTVShow.id)
                }
            } label: {
                Label("Watchlist", systemImage: tvBuddyTVShow == nil ? "plus" : "checkmark")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }

            Button {
                Task {
                    await actor.toggleShowWatched(showID: tmdbTVShow.id)
                }
            } label: {
                Label("Watched", systemImage: tvBuddyTVShow?.finishedWatching ?? false ? "eye.fill" : "eye")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }
        }
        .bold()
        .buttonStyle(.bordered)
    }

    private var overview: some View {
        Group {
            if tmdbTVShow.overview != nil {
                Text("Storyline")
                    .font(.title2)
                    .bold()
                Text(tmdbTVShow.overview ?? "")
            }
        }
    }

    private var genres: some View {
        Group {
            if let genres = tmdbTVShow.genres {
                WrappingHStack(genres, spacing: .constant(8), lineSpacing: 8) { genre in
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
    }

    private var seasons: some View {
        Group {
            if let numberOfSeasons = tmdbTVShow.numberOfSeasons {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Seasons")
                        .font(.title2)
                        .bold()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach((hasSpecials ? 0 : 1) ... numberOfSeasons, id: \.self) { seasonNumber in
                                NavigationLink {
                                    TVSeasonView(id: tmdbTVShow.id, seasonNumber: seasonNumber)
                                } label: {
                                    SeasonProgressView(tvShow: tmdbTVShow, seasonNumber: seasonNumber)
                                        .frame(width: 50)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private var castAndCrew: some View {
        Group {
            if let credits = credits, !credits.cast.isEmpty || !credits.crew.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
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
                                        role: cast.roles[0].character
                                    )
                                }
                                        
                                ForEach(credits.crew, id: \.uniqueId) { crew in
                                    CreditsItem(
                                        id: crew.id, 
                                        name: crew.name,
                                        role: crew.jobs[0].job
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var similarTVShows: some View {
        Group {
            if let tmdbTVShows = recommendations, !tmdbTVShows.isEmpty {
                MediaCollection(title: "Recommendations", media: tmdbTVShows)
            }
        }
    }
}
