//
//  TabBarView.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            Group {
                NavigationStack {
                    FeedView()
                        .toolbarBackground(.black, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }

                NavigationStack {
                    DiscoverView()
                        .toolbarBackground(.black, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "binoculars.fill")
                    Text("Discover")
                }

                NavigationStack {
                    SearchView()
                        .toolbarBackground(.black, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "text.magnifyingglass")
                    Text("Search")
                }

                NavigationStack {
                    ProfilView()
                        .toolbarBackground(.black, for: .navigationBar)
                }.tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profil")
                }
            }
            .toolbarBackground(.black, for: .tabBar)
        }
    }
}
