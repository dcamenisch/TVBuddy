//
//  PageableMovieList.swift
//  TVBuddy
//
//  Created by Danny on 21.11.2023.
//

import SwiftUI
import TMDb

struct PageableMovieList: View {
    let title: String
    let fetchMethod: (Bool) async -> [Movie]

    @State var movies = [Movie]()

    var body: some View {
        VStack(alignment: .leading) {
            if !title.isEmpty {
                Text(title)
                    .font(.title2)
                    .bold()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(movies.indices, id: \.self) { i in
                        MovieItem(movie: movies[i])
                            .onAppear(perform: {
                                if movies.endIndex - AppConstants.nextPageOffset == i {
                                    Task {
                                        movies = await fetchMethod(true)
                                    }
                                }
                            })
                    }
                }
            }
        }
        .task {
            movies = await fetchMethod(false)
        }
    }
}

struct MovieItem: View {
    @State private var poster: URL?

    let movie: Movie

    var body: some View {
        NavigationLink {
            MovieView(id: movie.id)
        } label: {
            ImageView(url: poster, placeholder: movie.title)
                .posterStyle(size: .medium)
        }
        .task {
            poster = await MovieStore.shared.poster(withID: movie.id)
        }
    }
}
