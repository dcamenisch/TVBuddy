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
	@EnvironmentObject private var movieStore: MovieStore
	
	private var trendingMovies: [TMDb.Movie] {
        movieStore.trending()
	}
	
	var body: some View {
		content
	}
    
    @ViewBuilder private var content: some View {
        if !trendingMovies.isEmpty {
            Pager(page: page, data: trendingMovies.prefix(10)) { movie in
                NavigationLink {
                    LazyView {
                        MovieDetailView(id: movie.id)
                    }
                } label: {
                    ImageView(title: movie.title, url: movieStore.backdropWithText(withID: movie.id))
                        .backdropStyle()
                        .padding(5)
                }
                .buttonStyle(.plain)
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
