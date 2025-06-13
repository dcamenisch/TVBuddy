//
//  TVShowHeader.swift
//  TVBuddy
//
//  Created by Danny on 08.07.22.
//

import NukeUI
import SwiftUI
import TMDb

struct TVEpisodeHeader: View {
    let series: TVSeries
    let episode: TVEpisode
    let backdropUrl: URL?

    let initialHeaderHeight: CGFloat = 350.0

    var body: some View {
        ZStack(alignment: .bottom) {
            if let url = backdropUrl {
                GeometryReader { geometry in
                    let minY = geometry.frame(in: .global).minY
                    
                    ImageView(url: url)
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
            
            VStack(alignment: .center, spacing: 5) {
                Text(episode.name)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .bold()

                NavigationLink {
                    TVShowView(id: series.id)
                } label: {
                    Text(series.name)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                
                HStack(spacing: 0) {
                    Text("\(metadata().joined(separator: "・"))")
                    
                    if let voteAverage = episode.voteAverage, voteAverage > 0.0 {
                        Text("・")
                        Image(systemName: "rosette").padding(.trailing, 2)
                        Text("\(Int(voteAverage * 10))%")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
    
    func metadata() -> [String] {
        var items = [String]()

        if let genre = series.genres?.first {
            items.append(genre.name)
        }
        
        if let airDate = episode.airDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none

            items.append(dateFormatter.string(from: airDate))
        }

        // TODO: Reenable runtime by adding it to the tmdb package
//        if let runtime = episode.runtime {
//            items.append(runtime.description + " min")
//        }
        
        return items
    }
}
