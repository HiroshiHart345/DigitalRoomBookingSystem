//
//  AuthService.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import FirebaseAuth

class AuthService {

    static let shared = AuthService()

    private init() {}

    func login(
        email: String,
        password: String,
        completion: @escaping(Result<AuthDataResult, Error>) -> Void
    ) {

        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { result, error in

            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }

        }

    }

    func register(
        email: String,
        password: String,
        completion: @escaping(Result<AuthDataResult, Error>) -> Void
    ) {

        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { result, error in

            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }

        }

    }


}
