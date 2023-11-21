//
//  MediaCollection.swift
//  TVBuddy
//
//  Created by Danny on 12.11.2023.
//

import SwiftUI
import TMDb

struct MediaCollection: View {
    
    let title: String
    
    let media: [Media] = []

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
//    let columns = [GridItem(.adaptive(minimum: PosterStyle.Size.width(.small)()))]

    var body: some View {
        VStack(alignment: .leading)  {
            
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                NavigationLink {
                    
                } label: {
                    Text("View All")
                        .font(.title2)
                        .bold()
                }
            }
            
            
            
            
        }
        
//        LazyVGrid(columns: columns, spacing: 10) {
//            ForEach(1 ... 100, id: \.self) { _ in
//                Rectangle()
//                    .aspectRatio(2 / 3, contentMode: .fill)
//            }
//        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MediaCollection(title: "Movie Collection")
}
