//
//  AuthViewModel.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import Combine
import FirebaseAuth 
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    static let shared = AuthViewModel()

    private init() {}

    @Published var email = ""
    @Published var password = ""

    @Published var name = ""
    @Published var organization = ""

    @Published var errorMessage = ""
    @Published var successMessage = ""

    @Published var loggedInUser: UserModel?

    private let authService = AuthService.shared
    private let authRepository = AuthRepository()

    func login() {

        authService.login(
            email: email,
            password: password
        ) { [weak self] result in

            DispatchQueue.main.async {

                switch result {

                case .success(let authResult):

                    self?.authRepository.fetchUser(
                        uid: authResult.user.uid
                    ) { result in

                        DispatchQueue.main.async {

                            switch result {

                            case .success(let user):

                                self?.loggedInUser = user

                            case .failure(let error):

                                self?.errorMessage =
                                error.localizedDescription

                            }

                        }

                    }

                case .failure(let error):

                    self?.errorMessage =
                    error.localizedDescription

                }

            }

        }

    }

}
