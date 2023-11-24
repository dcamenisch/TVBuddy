//
//  TVShowBody.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct TVShowBody: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore

    @State var credits: ShowCredits?
    @State var similar: [TVSeries]?

    @Query
    private var shows: [TVBuddyTVShow]
    private var _show: TVBuddyTVShow? { shows.first }

    private var tmdbTVShow: TVSeries

    init(tmdbTVShow: TVSeries, id: TVSeries.ID) {
        self.tmdbTVShow = tmdbTVShow
        _shows = Query(filter: #Predicate<TVBuddyTVShow> { $0.id == id })
    }

    private var hasSpecials: Bool {
        return tmdbTVShow.seasons?.count != tmdbTVShow.numberOfSeasons
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
            credits = await tvStore.credits(forTVSeries: tmdbTVShow.id)
            similar = await tvStore.similar(toTVSeries: tmdbTVShow.id)
        }
    }

    private var watchButtons: some View {
        HStack {
            Button {
                if let show = _show {
                    context.delete(show)
                } else {
                    insertTVShow(tmdbTVShow: tmdbTVShow, watched: false)
                }
            } label: {
                Label("Watchlist", systemImage: _show == nil ? "plus" : "checkmark")
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }

            Button {
                if let show = _show {
                    show.toggleWatched()
                } else {
                    insertTVShow(tmdbTVShow: tmdbTVShow, watched: true)
                }
            } label: {
                Label("Watched", systemImage: _show == nil ? "eye" : _show?.finishedWatching ?? false ? "eye.fill" : "eye")
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
                WrappingHStack(models: genres) { genre in
                    Text(genre.name)
                        .font(.headline)
                        .padding(.horizontal, 10.0)
                        .padding(.vertical, 8.0)
                        .background {
                            RoundedRectangle(cornerRadius: 15.0, style: .circular)
                                .foregroundStyle(.quaternary)
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
            if let tmdbTVShows = similar, !tmdbTVShows.isEmpty {
                MediaList(title: "Similar TV Shows", tmdbTVShows: tmdbTVShows)
            }
        }
    }

    private func insertTVShow(tmdbTVShow: TVSeries, watched: Bool = false) {
        let tvShow = TVBuddyTVShow(
            tvShow: tmdbTVShow, startedWatching: watched, finishedWatching: watched
        )
        context.insert(tvShow)

        Task {
            let tmdbEpisodes = await withTaskGroup(
                of: TVSeason?.self, returning: [TVSeason].self
            ) { group in
                for season in tmdbTVShow.seasons ?? [] {
                    group.addTask {
                        await tvStore.season(season.seasonNumber, forTVSeries: tmdbTVShow.id)
                    }
                }

                var childTaskResults = [TVSeason]()
                for await result in group {
                    if let result = result {
                        childTaskResults.append(result)
                    }
                }

                return childTaskResults
            }.compactMap { season in
                season.episodes
            }.flatMap {
                $0
            }

            tvShow.episodes.append(
                contentsOf: tmdbEpisodes.compactMap { TVBuddyTVEpisode(episode: $0, watched: watched) })
        }
    }
}
