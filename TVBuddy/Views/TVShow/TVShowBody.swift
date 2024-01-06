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

    @State var credits: ShowCredits?
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

            if let credits = credits, !credits.cast.isEmpty {
                PeopleList(credits: credits)
            }

            similarTVShows
        }
        .task {
            credits = await TVStore.shared.credits(forTVSeries: tmdbTVShow.id)
            recommendations = await TVStore.shared.recommendations(forTVSeries: tmdbTVShow.id)
        }
    }

    private var watchButtons: some View {
        HStack {
            Button {
                if let show = tvBuddyTVShow {
                    context.delete(show)
                    try! context.save()
                } else {
                    insertTVShow(id: tmdbTVShow.id, watched: false, isFavorite: false)
                }
            } label: {
                Label("Watchlist", systemImage: tvBuddyTVShow == nil ? "plus" : "checkmark")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }

            Button {
                if let show = tvBuddyTVShow {
                    show.toggleWatched()
                } else {
                    insertTVShow(id: tmdbTVShow.id, watched: true, isFavorite: false)
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
                VStack(alignment: .leading, spacing: 10) {
                    Text("Seasons")
                        .font(.title2)
                        .bold()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach((hasSpecials ? 0 : 1) ... numberOfSeasons, id: \.self) { season in
                                NavigationLink {
                                    TVSeasonView(id: tmdbTVShow.id, seasonNumber: season)
                                } label: {
                                    ZStack {
                                        Circle()
                                            .stroke(lineWidth: 4.0)
                                            .foregroundColor(.accentColor)
                                        Text(String(season))
                                            .font(.title2)
                                            .bold()
                                    }
                                    .padding(2)
                                    .frame(width: 40, height: 40)
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
    
    func insertTVShow(id: TVSeries.ID, watched: Bool, isFavorite: Bool) {
        Task {
            let container = context.container
            let actor = TVShowActor(modelContainer: container)
            await actor.insertTVShow(id: id, watched: watched, isFavorite: isFavorite)
        }
    }
}
