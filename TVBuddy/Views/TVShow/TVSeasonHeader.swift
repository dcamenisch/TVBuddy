//
//  TVSeasonHeader.swift
//  TVBuddy
//
//  Created by Danny on 01.10.2023.
//

import NukeUI
import SwiftUI
import TMDb

struct TVSeasonHeader: View {
    
    let season: TMDb.TVShowSeason
    let poster: URL?
    let backdrop: URL?
    
    var initialHeaderHeight: CGFloat = 350.0
    
    private var metadata: [String] {
        var items = [String]()

        if let releaseDate = season.airDate {
            items.append(DateFormatter.year.string(from: releaseDate))
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
                            .mask(LinearGradient(gradient: Gradient(colors: [.white, .clear]), startPoint: .bottom, endPoint: .top))
                    }
                    .offset(y: minY > 0 ? -minY : 0)
                    .frame(width: UIScreen.main.bounds.width, height: minY > 0 ? initialHeaderHeight + minY : initialHeaderHeight)
                }
                .frame(height: initialHeaderHeight)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(season.name)
                        .font(.system(size: 25, weight: .bold))
                    
                    HStack {
                        Text("\(metadata.joined(separator: "・"))")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, PosterStyle.Size.medium.width() + 15)
                .padding(.horizontal, 15)
            }
            
            ImageView(title: season.name, url: poster)
                .posterStyle(size: .medium)
                .padding(.horizontal, 10)
        }
    }

}
