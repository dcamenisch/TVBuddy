//
//  TabBarView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        let _ = Self._printChanges()
        
        TabView {
            Group {
                NavigationStack {
                    FeedView()
                        .toolbarBackground(.background1, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }

                NavigationStack {
                    DiscoverView()
                        .toolbarBackground(Color.background1, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "binoculars.fill")
                    Text("Discover")
                }

                NavigationStack {
                    SearchView()
                        .toolbarBackground(.background1, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "text.magnifyingglass")
                    Text("Search")
                }

                NavigationStack {
                    ProfilView()
                        .toolbarBackground(.background1, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profil")
                }
            }
            .toolbarBackground(.background1, for: .tabBar)
        }
    }
}
