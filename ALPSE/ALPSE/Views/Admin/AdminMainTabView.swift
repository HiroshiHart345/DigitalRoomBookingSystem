//
//  AdminMainTabView.swift
//  ALPSE
//

import SwiftUI

struct AdminMainTabView: View {
    let user: UserModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            AdminHomeView(user: user, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            AdminRoomsView()
                .tabItem {
                    Label("Rooms", systemImage: "door.left.hand.open")
                }
                .tag(1)

            AdminBookingsView()
                .tabItem {
                    Label("Booking", systemImage: "calendar")
                }
                .tag(2)

            AdminUsersView()
                .tabItem {
                    Label("User", systemImage: "person.2.fill")
                }
                .tag(3)

            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.alpseOrange)
    }
}
