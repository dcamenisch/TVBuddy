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
            NavigationStack {
                FeedView()
            }.tabItem {
                Image(systemName: "house.fill")
                Text("Feed")
            }

            NavigationStack {
                DiscoverView()
            }.tabItem {
                Image(systemName: "binoculars.fill")
                Text("Discover")
            }

            NavigationStack {
                SearchView()
            }.tabItem {
                Image(systemName: "text.magnifyingglass")
                Text("Search")
            }

            NavigationStack {
                ProfilView()
            }.tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profil")
            }
        }
    }
}
