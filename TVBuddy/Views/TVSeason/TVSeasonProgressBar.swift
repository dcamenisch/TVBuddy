//
//  TVSeasonProgressBar.swift
//  TVBuddy
//
//  Created by Danny on 07.01.2024.
//

import SwiftData
import SwiftUI
import TMDb

struct SeasonProgressView: View {
    @Environment(\.modelContext) private var context
    
    private let tvShow: TVSeries
    private let seasonNumber: Int
    
    @State private var progress: Double = 0.0
    
    init(tvShow: TVSeries, seasonNumber: Int) {
        self.tvShow = tvShow
        self.seasonNumber = seasonNumber
    }
    
    var body: some View {
        CircularProgressBar(progress: progress, strokeWidth: 5) {
            Text(seasonNumber == 0 ? "S" : String(seasonNumber))
                .foregroundStyle(Color.foreground2)
                .font(.title2)
                .bold()
        }
        .task {
            let allPredicate = #Predicate<TVBuddyTVEpisode> { $0.tvShow?.id ?? 0 == tvShow.id && $0.seasonNumber == seasonNumber }
            let totalCount = (try? context.fetchCount(FetchDescriptor(predicate: allPredicate))) ?? 0
            
            if totalCount == 0 {
                progress = 0.0
                return
            }
            
            let watchedPredicate = #Predicate<TVBuddyTVEpisode> { $0.tvShow?.id ?? 0 == tvShow.id && $0.seasonNumber == seasonNumber && $0.watched }
            let watchedCount = (try? context.fetchCount(FetchDescriptor(predicate: watchedPredicate))) ?? 0
                        
            progress = Double(watchedCount) / Double(totalCount)
        }
    }
}
