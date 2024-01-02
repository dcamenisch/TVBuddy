//
//  CircularProgressBar.swift
//  TVBuddy
//
//  Created by Danny on 01.01.2024.
//

import SwiftUI

struct CircularProgressBar: View {
    private let progress: Double
    private let progressText: String
    
    init(progress: Double, text: String) {
        self.progress = progress
        self.progressText = text
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 10))
            
            Circle()
                .trim(from: 0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
            
            Text(progressText)
                .font(.title)
        }
    }
}
