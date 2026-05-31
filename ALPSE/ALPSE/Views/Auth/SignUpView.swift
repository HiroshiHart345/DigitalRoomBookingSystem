//
//  SignUpView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import SwiftUI

struct SignUpView: View {

    @StateObject var viewModel = AuthViewModel.shared

    var body: some View {

        ZStack {

            Color.alpseOrange
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Text("SIGN UP")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                TextField(
                    "Name",
                    text: $viewModel.name
                )
                .padding()
                .background(Color.white)
                .cornerRadius(25)

                TextField(
                    "Organization",
                    text: $viewModel.organization
                )
                .padding()
                .background(Color.white)
                .cornerRadius(25)

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

                    viewModel.signUp()

                } label: {

                    Text("CREATE ACCOUNT")
                        .foregroundColor(.alpseOrange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)

                }

                Text(viewModel.errorMessage)
                    .foregroundColor(.red)

                Text(viewModel.successMessage)
                    .foregroundColor(.green)

            }
            .padding()

        }

    }

}

