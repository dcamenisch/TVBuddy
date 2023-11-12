//
//  MovieHeader.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import NukeUI
import SwiftUI
import TMDb

struct MovieHeader: View {

    let tmdbMovie: Movie
    let poster: URL?
    let backdrop: URL?

    var initialHeaderHeight: CGFloat = 350.0

    private var metadata: [String] {
        var items = [String]()

        if let runtime = tmdbMovie.runtime, runtime > 0 {
            let time = Int(runtime)
            let hours = Int(time / 60)
            let minutes = Int(time % 60)

            if hours == 0 {
                items.append("\(minutes) min")
            } else {
                items.append("\(hours) hr \(minutes) min")
            }
        }

        if let releaseDate = tmdbMovie.releaseDate {
            items.append(DateFormatter.year.string(from: releaseDate))
        }

        if let status = tmdbMovie.status {
            items.append(status.rawValue)
        }

        return items
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                GeometryReader { geometry in
                    let minY = geometry.frame(in: .global).minY

                    LazyImage(url: backdrop) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .clipped()
                                .aspectRatio(2, contentMode: .fill)
                        } else {
                            Rectangle()
                        }
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .foregroundColor(Color(uiColor: .systemBackground))
                            .frame(height: 100)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .bottom, endPoint: .top))
                    }
                    .offset(y: minY > 0 ? -minY : 0)
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: minY > 0 ? initialHeaderHeight + minY : initialHeaderHeight)
                }
                .frame(height: initialHeaderHeight)

                VStack(alignment: .leading, spacing: 5) {
                    if let voteAverage = tmdbMovie.voteAverage, voteAverage > 0.0 {
                        VoteLabel(voteAverage: voteAverage)
                    }

                    Text(tmdbMovie.title)
                        .font(.system(size: 25, weight: .bold))

                    HStack {
                        Text("\(metadata.joined(separator: "・"))")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, PosterStyle.Size.medium.width() + 15)
                .padding(.horizontal, 15)
            }

            ImageView(title: tmdbMovie.title, url: poster)
                .posterStyle(size: .medium)
                .padding(.horizontal)
        }
    }
}
