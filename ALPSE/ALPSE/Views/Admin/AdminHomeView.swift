//
//  AdminHomeView.swift
//  ALPSE
//

import SwiftUI

struct AdminHomeView: View {
    let user: UserModel
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {

            ZStack(alignment: .bottom) {
                Color.alpseOrange
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 12) {
                    HStack {
                        Text("HOME")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack {
                        Text("ADMIN")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
            .frame(height: 180)

            VStack(spacing: 8) {
                Text("Hi, \(user.name.isEmpty ? "Admin" : user.name)")
                    .font(.title2)
                    .bold()
                Text("What Do You Want To Do Today?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    adminTile(
                        title: "Rooms",
                        systemImage: "door.left.hand.open",
                        tabIndex: 1
                    )

                    adminTile(
                        title: "Booking",
                        systemImage: "calendar",
                        tabIndex: 2
                    )
                }

                adminTile(
                    title: "User",
                    systemImage: "person.2.fill",
                    tabIndex: 3
                )
            }

            Spacer()
            Spacer()
        }
    }

    private func adminTile(title: String, systemImage: String, tabIndex: Int) -> some View {
        Button {
            selectedTab = tabIndex
        } label: {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 32, weight: .semibold))
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(width: 130, height: 110)
            .background(Color.alpseOrange)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
    }
}
