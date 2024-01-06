//
//  MediaCollection.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MediaCollection<T:TVBuddyMediaItem>: View {
    let title: String
    let showAllButton: Bool
    let fetchMethod: ((Bool) async -> [T])?
    let posterSize: PosterStyle.Size
    
    private let mediaTmp: [T] = []
    @State private var media: [T]
    
    init(
        title: String = "",
        showAllButton: Bool = true,
        media: [T] = [],
        fetchMethod: ((Bool) async -> [T])? = nil,
        posterSize: PosterStyle.Size = .small
    ) {
        self.title = title
        self.showAllButton = showAllButton
        self.media = media
        self.fetchMethod = fetchMethod
        self.posterSize = posterSize
    }

    var body: some View {        
        VStack(alignment: .leading) {
            if !title.isEmpty || showAllButton {
                upperBar
            }
            
            horizontalList
        }
        .task {
            if let fetchMethod = fetchMethod {
                Task {
                    media = await fetchMethod(false)
                }
            }
        }
    }
    
    var upperBar: some View {
        HStack(alignment: .bottom) {
            Text(title)
                .font(.title2)
                .bold()

            Spacer()

            if showAllButton {
                NavigationLink {
                    verticalGrid
                        .navigationTitle(title)
                } label: {
                    Text("Show all")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    var horizontalList: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(Array(media.enumerated()), id: \.element) { index, element in
                    MediaListItem(mediaItem: element)
                        .posterStyle(size: posterSize)
                        .onAppear(perform: {
                            if let fetchMethod = fetchMethod, media.endIndex - AppConstants.nextPageOffset == index {
                                Task {
                                    media = await fetchMethod(true)
                                }
                            }
                        })
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    var verticalGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 10) {
                ForEach(Array(media.enumerated()), id: \.element) { index, element in
                    MediaListItem(mediaItem: element)
                        .posterStyle()
                        .onAppear(perform: {
                            if let fetchMethod = fetchMethod, media.endIndex - AppConstants.nextPageOffset == index {
                                Task {
                                    media = await fetchMethod(true)
                                }
                            }
                        })
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
    }
}

struct MediaListItem<T:TVBuddyMediaItem>: View {
    @State var poster: URL?

    let mediaItem: T

    var body: some View {
        NavigationLink {
            mediaItem.detailView
        } label: {
            ImageView(url: poster, placeholder: mediaItem.name)
        }
        .task {
            poster = await mediaItem.getPosterURL()
        }
    }
}
