//
//  PageableTVShowList.swift
//  TVBuddy
//
//  Created by Danny on 21.11.2023.
//

import SwiftUI
import TMDb

struct PageableTVShowList: View {
    let title: String
    let fetchMethod: (Bool) async -> [TVSeries]

    @State var tvSeries = [TVSeries]()

    var body: some View {        
        VStack(alignment: .leading) {
            if !title.isEmpty {
                Text(title)
                    .font(.title2)
                    .bold()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(tvSeries.indices, id: \.self) { i in
                        TVShowItem(tvSeries: tvSeries[i])
                            .onAppear(perform: {
                                if tvSeries.endIndex - AppConstants.nextPageOffset == i {
                                    Task {
                                        tvSeries = await fetchMethod(true)
                                    }
                                }
                            })
                    }
                }
            }
        }
        .task {
            tvSeries = await fetchMethod(false)
        }
    }
}

struct TVShowItem: View {
    @State var poster: URL?

    let tvSeries: TVSeries

    var body: some View {
        NavigationLink {
            TVShowView(id: tvSeries.id)
        } label: {
            ImageView(title: tvSeries.name, url: poster)
                .posterStyle(size: .medium)
        }
        .task {
            poster = await TVStore.shared.poster(withID: tvSeries.id)
        }
    }
}
