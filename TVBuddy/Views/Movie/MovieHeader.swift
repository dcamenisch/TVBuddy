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
    let movie: Movie
    let poster: URL?
    let backdrop: URL?
    
    let initialHeaderHeight: CGFloat = 350.0
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                backdropImage
                
                VStack(alignment: .leading, spacing: 5) {
                    if let voteAverage = movie.voteAverage, voteAverage > 0.0 {
                        VoteLabel(voteAverage: voteAverage)
                    }
                    
                    Text(movie.title)
                        .font(.system(size: 25, weight: .bold))
                    
                    Text("\(movie.metadata.joined(separator: "・"))")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, PosterStyle.Size.medium.width() + 15)
                .padding(.horizontal, 15)
            }
            
            ImageView(url: poster, placeholder: movie.title)
                .posterStyle(size: .medium)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var backdropImage: some View {
        if let _ = backdrop {
            GeometryReader { geometry in
                let minY = geometry.frame(in: .global).minY
                
                ImageView(url: backdrop)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .foregroundColor(Color(uiColor: .systemBackground))
                            .frame(height: 100)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .bottom, endPoint: .top
                                ))
                    }
                    .offset(y: minY > 0 ? -minY : 0)
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: minY > 0 ? initialHeaderHeight + minY : initialHeaderHeight
                    )
            }
            .frame(height: initialHeaderHeight)
        }
    }
}
