//
//  StudentHomeView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import SwiftUI
import FirebaseAuth

struct StudentHomeView: View {

    let user: UserModel

    var body: some View {

        TabView {

            StudentDashboardView(user: user)
                .tabItem {
                    Image(systemName: "house.fill")
                }

            BookingHistoryView(user: user)
                .tabItem {
                    Image(systemName: "clock.fill")
                }

            ProfileView(user: user)
                .tabItem {
                    Image(systemName: "person.fill")
                }

        }
        .tint(.alpseOrange)

    }
    
}
