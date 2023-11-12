//
//  MediaCarousel.swift
//  TVBuddy
//
//  Created by Danny on 10.07.22.
//

import SwiftUI
import SwiftUIPager
import TMDb

struct MediaCarousel: View {
    @StateObject var page: Page = .first()
    
    var trendingMovies: [TMDb.Movie]

    var body: some View {
        content
    }

    @ViewBuilder private var content: some View {
        if !trendingMovies.isEmpty {
            Pager(page: page, data: trendingMovies.prefix(10)) { movie in
                MediaCarouselItem(movie: movie)
            }
            .bounces(true)
            .interactive(scale: 0.95)
            .itemSpacing(20)
            .loopPages()
            .pagingPriority(.high)
            .aspectRatio(1.77, contentMode: .fit)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
                .background {
                    Color.secondary
                        .backdropStyle()
                        .aspectRatio(1.77, contentMode: .fill)
                        .padding(.horizontal, 10)
                }
        }
    }

}

struct MediaCarouselItem: View {
    
    let movie: TMDb.Movie
    
    @EnvironmentObject private var movieStore: MovieStore
    
    @State var backdropWithText: URL?
    
    var body: some View {
        NavigationLink {
            LazyView(MovieView(id: movie.id))
        } label: {
            ImageView(title: movie.title, url: backdropWithText)
                .backdropStyle()
                .padding(5)
        }
        .buttonStyle(.plain)
        .task {
            backdropWithText = await movieStore.backdropWithText(withID: movie.id)
        }
    }
}
