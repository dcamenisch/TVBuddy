//
//  CastList.swift
//  tvTracker
//
//  Created by Danny on 03.07.22.
//

import SwiftUI
import TMDb

struct PeopleList: View {
	
	let credits: TMDb.ShowCredits
	
	@EnvironmentObject private var personStore: PersonStore
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(credits.cast) { cast in
					VStack(spacing: 5) {
                        ImageView(title: cast.name, url: personStore.image(forPerson: cast.id))
                            .posterStyle(size: .medium)
						
						Text(cast.name)
							.font(.system(size: 15, weight: .semibold))
							.multilineTextAlignment(.center)
							.fixedSize(horizontal: false, vertical: true)
							.lineLimit(2)
						
						Text(cast.character)
							.font(.system(size: 15, weight: .regular))
							.multilineTextAlignment(.center)
							.fixedSize(horizontal: false, vertical: true)
							.lineLimit(2)
						
						Spacer()
					}
					.padding(.top, 10)
					.frame(width: PosterStyle.Size.medium.width() + 10)
				}
			}
		}
	}
}
