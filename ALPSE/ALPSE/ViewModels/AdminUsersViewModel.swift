//
//  AdminUsersViewModel.swift
//  ALPSE
//

import Foundation
import Combine

class AdminUsersViewModel: ObservableObject {

    @Published var users: [UserModel] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    private let repository = AuthRepository()

    static let availableRoles: [String] = [
        "student",
        "Student Affairs",
        "Academic Support",
        "Property Management",
        "admin"
    ]

    func fetchUsers() {
        isLoading = true
        repository.fetchAllUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func groupedByRole() -> [(role: String, users: [UserModel])] {
        let groups = Dictionary(grouping: users) { displayRole(for: $0.role) }
        let order = ["Student Affairs", "Academic Support", "Property Management", "Student", "Admin"]
        return order.compactMap { key in
            guard let entries = groups[key], !entries.isEmpty else { return nil }
            return (role: key, users: entries.sorted { $0.name < $1.name })
        }
    }

    private func displayRole(for raw: String) -> String {
        let lower = raw.lowercased()
        if lower.contains("academic") { return "Academic Support" }
        if lower.contains("property") { return "Property Management" }
        if lower.contains("student affair") { return "Student Affairs" }
        if lower == "admin" { return "Admin" }
        return "Student"
    }

    func updateName(uid: String, newName: String) {
        repository.updateUserName(uid: uid, newName: newName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchUsers()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteUser(uid: String) {
        repository.deleteUser(uid: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchUsers()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func createUser(
        name: String,
        email: String,
        password: String,
        role: String,
        organization: String
    ) {
        repository.createUserAsAdmin(
            name: name,
            email: email,
            password: password,
            role: role,
            organization: organization
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchUsers()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
