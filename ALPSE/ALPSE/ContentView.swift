//
//  ContentView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 28/05/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewModel = AuthViewModel.shared

    var body: some View {

        NavigationStack {

            if let user = viewModel.loggedInUser {

                StudentHomeView(user: user)

            } else {

                LoginView()

            }

        }

    }

}
