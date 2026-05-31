//
//  StudentDashboardView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//

import SwiftUI

struct StudentDashboardView: View {

    let user: UserModel

    var body: some View {

        ZStack {

            Color.alpseOrange
                .ignoresSafeArea()

            VStack {

                VStack(alignment: .leading, spacing: 10) {

                    HStack {

                        VStack(alignment: .leading) {

                            Text("Welcome Back")
                                .foregroundColor(.white)

                            Text(user.name)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)

                        }

                        Spacer()

                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)

                    }

                }
                .padding()

                Spacer()

                NavigationLink {

                    RoomListView(user: user)

                } label: {

                    VStack(spacing: 12) {

                        ZStack {

                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)

                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.alpseOrange)

                        }

                        Text("BOOK ROOM")
                            .fontWeight(.bold)
                            .foregroundColor(.alpseOrange)
                            .frame(width: 140, height: 50)
                            .background(Color.white)
                            .cornerRadius(15)

                    }

                }

                Spacer()

            }

        }
        .navigationBarBackButtonHidden(true)

    }

}
