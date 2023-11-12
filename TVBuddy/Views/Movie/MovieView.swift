//
//  MovieView.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MovieView: View {
    let id: TMDb.Movie.ID

    @State var offset: CGFloat = 0.0
    @State var visibility: Visibility = .hidden
    
    @State var tmdbMovie: TMDb.Movie?
    @State var poster: URL?
    @State var backdrop: URL?

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var movieStore: MovieStore

    private var progress: CGFloat { offset / 350.0 }

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
                    Text(tmdbMovie?.title ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .opacity(max(0, -22.0 + 20.0 * progress))
                }
            }
            .task {
                tmdbMovie = await movieStore.movie(withID: id)
                poster = await movieStore.poster(withID: id)
                backdrop = await movieStore.backdrop(withID: id)
            }
    }

    @ViewBuilder private var content: some View {
        if let tmdbMovie = tmdbMovie {
            OffsettableScrollView(showsIndicators: false) { point in
                offset = -point.y
                visibility = offset > 290 ? .visible : .hidden
            } content: {
                MovieHeader(tmdbMovie: tmdbMovie, poster: poster, backdrop: backdrop)
                    .padding(.bottom, 10)
                MovieBody(tmdbMovie: tmdbMovie, id: id)
                    .padding(.horizontal)
            }
        } else {
            ProgressView()
        }
    }
}
