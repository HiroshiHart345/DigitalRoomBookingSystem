//
//  AuthRepository.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import FirebaseFirestore

class AuthRepository {

    private let db = Firestore.firestore()

    func fetchUser(
        uid: String,
        completion: @escaping(Result<UserModel, Error>) -> Void
    ) {

        db.collection("users")
            .document(uid)
            .getDocument { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = snapshot?.data() else { return }

                let user = UserModel(
                    id: uid,
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    role: data["role"] as? String ?? "",
                    organization: data["organization"] as? String ?? ""
                )

                completion(.success(user))

            }

    }

    func saveUser(
        user: UserModel,
        completion: @escaping(Result<Void, Error>) -> Void
    ) {

        db.collection("users")
            .document(user.id)
            .setData([

                "name": user.name,
                "email": user.email,
                "role": user.role,
                "organization": user.organization

            ]) { error in

                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }

            }

    }

}
