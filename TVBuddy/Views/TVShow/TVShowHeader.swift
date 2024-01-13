//
//  TVShowHeader.swift
//  TVBuddy
//
//  Created by Danny on 08.07.22.
//

import NukeUI
import SwiftUI
import TMDb

struct TVShowHeader: View {
    let show: TVSeries
    let poster: URL?
    let backdrop: URL?

    let initialHeaderHeight: CGFloat = 350.0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                if let _ = backdrop {
                    GeometryReader { geometry in
                        let minY = geometry.frame(in: .global).minY

                        ImageView(url: backdrop)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .foregroundColor(Color(uiColor: .systemBackground))
                                .frame(height: 100)
                                .mask(LinearGradient(gradient: Gradient(colors: [.white, .clear]), startPoint: .bottom, endPoint: .top))
                        }
                        .offset(y: minY > 0 ? -minY : 0)
                        .frame(width: UIScreen.main.bounds.width, height: minY > 0 ? initialHeaderHeight + minY : initialHeaderHeight)
                    }
                    .frame(height: initialHeaderHeight)
                }

                VStack(alignment: .leading, spacing: 5) {
                    if let voteAverage = show.voteAverage, voteAverage > 0.0 {
                        VoteLabel(voteAverage: voteAverage)
                    }

                    Text(show.name)
                        .font(.system(size: 25, weight: .bold))

                    HStack {
                        Text("\(show.metadata.joined(separator: "・"))")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, PosterStyle.Size.medium.width() + 15)
                .padding(.horizontal, 15)
            }

            ImageView(url: poster, placeholder: show.name)
                .posterStyle(size: .medium)
                .padding(.horizontal, 10)
        }
    }
}
