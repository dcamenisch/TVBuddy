//
//  TVShowDetailView.swift
//  TVBuddy
//
//  Created by Danny on 08.07.22.
//

import SwiftData
import SwiftUI
import TMDb

struct TVShowDetailView: View {
	
	let id: TMDb.TVShow.ID
	
    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
    @Query
    private var shows: [TVSeries]
    private var _show: TVSeries? { shows.first }

    private var show: TMDb.TVShow? { tvStore.show(withID: id) }
    private var poster: URL? { tvStore.poster(withID: id) }
    private var backdrop: URL? { tvStore.backdrop(withID: id) }
    private var progress: CGFloat { offset / 350.0 }
    
    private var hasSpecials: Bool {
        return show?.seasons?.count != show?.numberOfSeasons
    }
	
    init(id: TMDb.TVShow.ID) {
        self.id = id
        _shows = Query(filter: #Predicate<TVSeries> { $0.id == id })
    }
    
    var body: some View {
        content
            .toolbarBackground(.black)
            .toolbarBackground(visibility, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(show?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
            }
    }
	
	@ViewBuilder private var content: some View {
        if let show = show {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                visibility = offset > 290 ? .visible : .hidden
            } content: {
                TVShowDetailHeader(show: show, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                
                VStack {
                    watchButtons
                    details
                }
                .padding(.horizontal)
            }
        } else {
            ProgressView()
        }
	}
    
    private var watchButtons: some View {
        HStack {
            Button {
                if let show = _show {
                    context.delete(show)
                } else {
                    insertTVSeries(tmdbSeries: show!)
                }
            } label: {
                HStack {
                    Image(systemName: _show == nil ? "plus" : "checkmark")
                    Text("Watchlist")
                }
                .bold()
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button {
                if let show = _show {
                    show.finishedWatching.toggle()
                    try? context.save()
                } else {
                    insertTVSeries(tmdbSeries: show!)
                }
            } label: {
                HStack {
                    Image(systemName: _show == nil ? "eye" : _show?.finishedWatching ?? false ? "eye.fill" : "eye")
                    Text("Watched")
                }
                .bold()
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var details: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Storyline for the TV Series
            if let overview = show!.overview {
                Text("Storyline")
                    .font(.title2)
                    .bold()
                Text(overview)
            }
            
            // Seasons
            if show!.numberOfSeasons != nil {
                Text("Seasons")
                    .font(.title2)
                    .bold()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach((hasSpecials ? 0 : 1)...show!.numberOfSeasons!, id: \.self) { season in
                            NavigationLink {
                                TVSeasonView(seasonNumber: season, tvShowID: id)
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
            
            // Cast
            if let credits = tvStore.credits(forTVShow: id), !credits.cast.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Cast")
                        .font(.title2)
                        .bold()
                    PeopleList(credits: credits)
                }
            }
            
            // Similar TV Series
            if let shows = tvStore.recommendations(forTVShow: id), !shows.isEmpty {
                MediaList(shows: shows, title: "Similar TV Series")
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func insertTVSeries(tmdbSeries: TMDb.TVShow) {
        let tvSeries: TVSeries = TVSeries(tvSeries: tmdbSeries)
        context.insert(tvSeries)
        
        let tmdbEpisodes = tmdbSeries.seasons?.compactMap({ season in
            tvStore.season(season.seasonNumber, forTVShow: tmdbSeries.id)
        }).compactMap({ season in
            season.episodes
        }).flatMap({
            $0
        })
        
        tvSeries.episodes.append(contentsOf: tmdbEpisodes?.compactMap { TVEpisode(tvEpisode: $0) } ?? [])
    }
}
