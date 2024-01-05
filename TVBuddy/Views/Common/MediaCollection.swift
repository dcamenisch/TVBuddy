//
//  MediaCollection.swift
//  TVBuddy
//
//  Created by Danny on 17.09.2023.
//

import SwiftUI
import TMDb

struct MediaCollection: View {
    let title: String
    let showAllButton: Bool
    
    private var media = [any TVBuddyMediaItem]()

    init(
        title: String = "",
        showAllButton: Bool = true,
        media: [any TVBuddyMediaItem] = []
    ) {
        self.title = title
        self.showAllButton = showAllButton
        self.media = media
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !title.isEmpty || showAllButton {
                upperBar
            }
            
            horizontalList
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
                ForEach(media, id: \.id) { item in
                    MediaListItem(mediaItem: item)
                        .posterStyle(size: .small)
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    var verticalGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 10) {
                ForEach(media, id: \.id) { item in
                    MediaListItem(mediaItem: item)
                        .posterStyle()
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.never)
    }
}

struct MediaListItem: View {
    @State var poster: URL?

    let mediaItem: any TVBuddyMediaItem

    var body: some View {
        NavigationLink {
            AnyView(mediaItem.getDetailView())
        } label: {
            ImageView(url: poster, placeholder: mediaItem.name)
        }
        .task {
            poster = await mediaItem.getPosterURL()
        }
    }
}
