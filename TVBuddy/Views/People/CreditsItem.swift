//
//  CreditsView.swift
//  TVBuddy
//
//  Created by Danny on 19.06.2024.
//

import NukeUI
import SwiftUI
import TMDb

struct CreditsItem: View {
    let id: Person.ID
    let name: String
    let role: String
    
    @State var url: URL?
    
    var body: some View {
        VStack {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray)
        
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                }
            }
            .frame(width: 110, height: 110)
            
            Group {
                Text(name)
                    .bold()
                    .font(.subheadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                                    
                Text(role)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 110)
        }
        .task {
            url = await PersonStore.shared.images(forPerson: id).first
        }
    }
}

// Since a crew member could have worked multiple jobs, they could be contained
// multiple times causing their ID to not be unique
extension CrewMember {
    var uniqueId: String {
        self.name + self.job + String(self.id)
    }
}

extension AggregrateCrewMember {
    var uniqueId: String {
        self.name + self.jobs[0].job + String(self.id)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CreditsItem(
        id: 58224,
        name: "Jason Sudeikis",
        role: "Ted Lasso"
    )
}
