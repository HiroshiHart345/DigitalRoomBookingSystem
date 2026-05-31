//
//  LoginView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import SwiftUI

struct LoginView: View {

    @StateObject var viewModel = AuthViewModel.shared

    var body: some View {

        ZStack {

            Color.alpseOrange
                .ignoresSafeArea()

            VStack(spacing: 20) {
                
                Spacer()
                
                Text("LOGIN")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                
                TextField(
                    "Email",
                    text: $viewModel.email
                )
                .padding()
                .background(Color.white)
                .cornerRadius(25)

                SecureField(
                    "Password",
                    text: $viewModel.password
                )
                .padding()
                .background(Color.white)
                .cornerRadius(25)

                Button {

                    viewModel.login()

                } label: {

                    Text("LOGIN")
                        .foregroundColor(.alpseOrange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)

                }

                Text(viewModel.errorMessage)
                    .foregroundColor(.red)

                NavigationLink {

                    SignUpView()

                } label: {

                    Text("Don't Have An Account ? Sign Up")
                        .foregroundColor(.white)

                }

                Spacer()

            }
            .padding()

        }

    }
    
}


