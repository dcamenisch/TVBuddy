//
//  PersonRow.swift
//  TVBuddy
//
//  Created by Danny on 02.01.2024.
//

import SwiftUI
import TMDb

struct PersonRow: View {
    let person: Person

    @EnvironmentObject private var personStore: PersonStore
    @State var image: URL?

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            ImageView(title: person.name, url: image)
                .posterStyle(size: .tiny)

            VStack(alignment: .leading, spacing: 5) {
                Text(person.name)
                    .font(.system(size: 22, weight: .bold))
                    .lineLimit(2)
            }
        }
        .task(id: person) {
            image = await personStore.image(forPerson: person.id)
        }
    }
}
