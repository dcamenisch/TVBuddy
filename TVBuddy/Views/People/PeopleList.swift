//
//  PeopleList.swift
//  TVBuddy
//
//  Created by Danny on 03.07.22.
//

import SwiftUI
import TMDb

struct PeopleList: View {

    let credits: TMDb.ShowCredits
    
    @State private var selected = 0
    var options = ["Cast", "Crew"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cast and Crew")
                .font(.title2)
                .bold()
            
            Picker("", selection: $selected) {
                ForEach(0..<options.count, id: \.self) { option in
                    Text(options[option])
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)
            
            if selected == 0 {
                ForEach(credits.cast) { castMember in
                    CastItem(castMember: castMember)
                }
            } else {
                ForEach(credits.crew) { crewMember in
                    CrewItem(crewMember: crewMember)
                }
            }
        }
    }
}

struct CastItem: View {
    
    let castMember: TMDb.CastMember
    
    @EnvironmentObject private var personStore: PersonStore
    @State var image: URL?
    
    var body: some View {
        HStack {
            ImageView(title: castMember.name, url: image)
                .posterStyle(size: .tiny)
            
            VStack(alignment: .leading) {
                Text(castMember.name)
                    .font(.title3)
                    .bold()
                    .lineLimit(2)

                Text(castMember.character)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .task {
            image = await personStore.image(forPerson: castMember.id)
        }
    }
}

struct CrewItem: View {
    
    let crewMember: TMDb.CrewMember
    
    @EnvironmentObject private var personStore: PersonStore
    @State var image: URL?
    
    var body: some View {
        HStack {
            ImageView(title: crewMember.name, url: image)
                .posterStyle(size: .tiny)
            
            VStack(alignment: .leading) {
                Text(crewMember.name)
                    .font(.title3)
                    .bold()
                    .lineLimit(2)

                Text(crewMember.job)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .task {
            image = await personStore.image(forPerson: crewMember.id)
        }
    }
}
