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
	
	let id: TMDb.TVShow.ID
	
    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tvStore: TVStore
    
    @State var tmdbTVShow: TMDb.TVShow?
    @State var poster: URL?
    @State var backdrop: URL?
    
    @Query
    private var shows: [TVShow]
    private var _show: TVShow? { shows.first }

    private var progress: CGFloat { offset / 350.0 }
	
    init(id: TMDb.TVShow.ID) {
        self.id = id
        _shows = Query(filter: #Predicate<TVShow> { $0.id == id })
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
                    Text(tmdbTVShow?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
            }
            .task {
                tmdbTVShow = await tvStore.show(withID: id)
                poster = await tvStore.poster(withID: id)
                backdrop = await tvStore.backdrop(withID: id)
            }
    }
	
	@ViewBuilder private var content: some View {
        if let tmdbTVShow = tmdbTVShow {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                visibility = offset > 290 ? .visible : .hidden
            } content: {
                TVShowHeader(show: tmdbTVShow, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                TVShowBody(tmdbTVShow: tmdbTVShow, id: id)
                    .padding(.horizontal)
            }
        } else {
            ProgressView()
        }
	}
}