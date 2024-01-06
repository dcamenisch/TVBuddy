//
//  TVShowView.swift
//  TVBuddy
//
//  Created by Danny on 08.07.22.
//

import SwiftData
import SwiftUI
import TMDb

struct TVShowView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) private var presentationMode

    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden

    @State var tmdbTVShow: TVSeries?
    @State var poster: URL?
    @State var backdrop: URL?

    @Query
    private var shows: [TVBuddyTVShow]
    private var _show: TVBuddyTVShow? { shows.first }

    let id: TVSeries.ID

    private var progress: CGFloat { backdrop != nil ? offset / 350.0 : offset / 100.0}
    
    init(id: TVSeries.ID) {
        self.id = id
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
                    Text(tmdbTVShow?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if let show = _show {
                        Button {
                            show.isArchived.toggle()
                        } label: {
                            Image(systemName: show.isArchived ? "archivebox.fill" : "archivebox")
                                .fontWeight(.semibold)
                                .foregroundStyle(.accent)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let show = _show {
                            show.isFavorite.toggle()
                        } else if let tmdbTVShow = tmdbTVShow {
                            insertTVShow(id: tmdbTVShow.id, watched: true, isFavorite: true)
                        }
                    } label: {
                        Image(systemName: _show?.isFavorite ?? false ? "heart.fill" : "heart")
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                    }
                }
            }
            .task {
                tmdbTVShow = await TVStore.shared.show(withID: id)
                poster = await TVStore.shared.poster(withID: id)
                backdrop = await TVStore.shared.backdrop(withID: id)
            }
    }

    @ViewBuilder private var content: some View {
        if let tmdbTVShow = tmdbTVShow {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                if backdrop == nil {
                    visibility = offset > 0 ? .visible : .hidden
                } else {
                    visibility = offset > 290 ? .visible : .hidden
                }
            } content: {
                TVShowHeader(show: tmdbTVShow, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                TVShowBody(tmdbTVShow: tmdbTVShow, tvBuddyTVShow: _show)
                    .padding(.horizontal)
            }
        } else {
            ProgressView()
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
