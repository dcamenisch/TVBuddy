//
//  VoteLabel.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import SwiftUI

struct VoteLabel: View {
    let voteAverage: Double

    private var voteColor: Color {
        if voteAverage < 4 {
            return .red
        }

        if voteAverage < 5.5 {
            return .orange
        }

        if voteAverage < 7.0 {
            return .yellow
        }

        return .green
    }

    var body: some View {
        Label("\(Int(voteAverage * 10))%", systemImage: "rosette")
            .foregroundColor(voteColor)
    }
}
