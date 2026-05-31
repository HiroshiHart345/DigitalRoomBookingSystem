//
//  ProfileView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {

    let user: UserModel

    @StateObject var authViewModel = AuthViewModel.shared

    var body: some View {

        ZStack {

            Color.alpseOrange
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Spacer()

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)

                Text(user.name)
                    .font(.title)
                    .foregroundColor(.white)

                Text(user.email)
                    .foregroundColor(.white)

                Text(user.organization)
                    .foregroundColor(.white)

                Button {

                    authViewModel.logout()

                } label: {

                    Text("LOGOUT")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(15)

                }

                Spacer()

            }

        }
        .navigationBarBackButtonHidden(true)

    }
    
}
