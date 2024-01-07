//
//  CircularProgressBar.swift
//  TVBuddy
//
//  Created by Danny on 01.01.2024.
//

import SwiftUI

struct CircularProgressBar<Content>: View where Content: View {
    private let progress: Double
    private let strokeWidth: CGFloat
    private let content: () -> Content
    
    init(progress: Double, strokeWidth: CGFloat = 10, @ViewBuilder content: @escaping () -> Content) {
        self.progress = progress
        self.strokeWidth = strokeWidth
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.background3, style: StrokeStyle(lineWidth: strokeWidth))
                .background {
                    Circle()
                        .foregroundStyle(Color.background2)
                }
            
            Circle()
                .trim(from: 0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)

            content()
        }
        .padding(strokeWidth / 2)
    }
}
