//
//  TVSeasonView.swift
//  TVBuddy
//
//  Created by Danny on 01.10.2023.
//

import SwiftData
import SwiftUI
import TMDb

struct TVSeasonView: View {
    let id: TVSeries.ID
    let seasonNumber: Int

    @Environment(\.presentationMode) private var presentationMode

    @State private var offset: CGFloat = 0.0
    @State private var visibility: Visibility = .hidden

    @State var tmdbTVShow: TVSeries?
    @State var tmdbSeason: TVSeason?
    @State var poster: URL?
    @State var backdrop: URL?
    
    @Query
    private var shows: [TVBuddyTVShow]
    private var _show: TVBuddyTVShow? { shows.first }

    private var progress: CGFloat { backdrop != nil ? offset / 350.0 : offset / 100.0}

    init(id: TVSeries.ID, seasonNumber: Int) {
        self.id = id
        self.seasonNumber = seasonNumber
        _shows = Query(filter: #Predicate<TVBuddyTVShow> { $0.id == id })
    }
    
    var body: some View {        
        content
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
                    Text(tmdbSeason?.name ?? "Season \(seasonNumber)")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
            }
            .task {
                tmdbTVShow = try? await TVStore.shared.show(withID: id)
                tmdbSeason = try? await TVStore.shared.season(seasonNumber, forTVSeries: id)
                poster = await TVStore.shared.posters(id: id, season: seasonNumber).first
                backdrop = await TVStore.shared.backdrops(id: id).first
            }
    }

    @ViewBuilder 
    private var content: some View {
        if let tmdbSeason = tmdbSeason, let tmdbTVShow = tmdbTVShow {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                if backdrop == nil {
                    visibility = offset > 0 ? .visible : .hidden
                } else {
                    visibility = offset > 290 ? .visible : .hidden
                }
            } content: {
                TVSeasonHeader(season: tmdbSeason, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                TVSeasonBody(tvShow: tmdbTVShow, tvSeason: tmdbSeason, tvBuddyTVShow: _show)
                    .padding(.horizontal)
                Spacer()
            }
        } else {
            ProgressView()
        }
    }
}
