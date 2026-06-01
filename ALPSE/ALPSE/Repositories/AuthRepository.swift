//
//  AuthRepository.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import FirebaseCore
import FirebaseAuth
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

    func fetchAllUsers(
        completion: @escaping (Result<[UserModel], Error>) -> Void
    ) {

        db.collection("users")
            .getDocuments { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let users = documents.map { doc -> UserModel in
                    let data = doc.data()
                    return UserModel(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        role: data["role"] as? String ?? "",
                        organization: data["organization"] as? String ?? ""
                    )
                }

                completion(.success(users))
            }
    }

    func updateUserName(
        uid: String,
        newName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        db.collection("users")
            .document(uid)
            .updateData(["name": newName]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func deleteUser(
        uid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        db.collection("users")
            .document(uid)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    /// Creates a new auth account + user document without disturbing the
    /// admin's current session. Uses a secondary FirebaseApp instance so
    /// `Auth.auth().currentUser` (the admin) stays signed in.
    func createUserAsAdmin(
        name: String,
        email: String,
        password: String,
        role: String,
        organization: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        guard let options = FirebaseApp.app()?.options else {
            completion(.failure(NSError(
                domain: "AdminUserCreation",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Firebase not configured"]
            )))
            return
        }

        let secondaryAppName = "AdminUserCreation"

        if FirebaseApp.app(name: secondaryAppName) == nil {
            FirebaseApp.configure(name: secondaryAppName, options: options)
        }

        guard let secondaryApp = FirebaseApp.app(name: secondaryAppName) else {
            completion(.failure(NSError(
                domain: "AdminUserCreation",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Could not init secondary app"]
            )))
            return
        }

        let secondaryAuth = Auth.auth(app: secondaryApp)

        secondaryAuth.createUser(withEmail: email, password: password) { [weak self] result, error in

            if let error = error {
                secondaryApp.delete { _ in }
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                secondaryApp.delete { _ in }
                completion(.failure(NSError(
                    domain: "AdminUserCreation",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Missing UID"]
                )))
                return
            }

            let newUser = UserModel(
                id: uid,
                name: name,
                email: email,
                role: role,
                organization: organization
            )

            self?.saveUser(user: newUser) { saveResult in
                try? secondaryAuth.signOut()
                secondaryApp.delete { _ in }
                completion(saveResult)
            }
        }
    }

}
