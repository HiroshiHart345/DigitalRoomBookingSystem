//
//  AdminUsersView.swift
//  ALPSE
//

import SwiftUI

struct AdminUsersView: View {

    @StateObject private var viewModel = AdminUsersViewModel()

    @State private var showInsertSheet = false
    @State private var editingUser: UserModel? = nil
    @State private var userPendingDeletion: UserModel? = nil

    var body: some View {
        ZStack {
            Color.alpseOrange.ignoresSafeArea()

            VStack(spacing: 0) {

                Text("USER")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)

                ZStack(alignment: .top) {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text("MASTER DATA USER")
                                .font(.subheadline)
                                .foregroundColor(.alpseOrange)
                            Spacer()
                            Button {
                                showInsertSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                        Divider()

                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.groupedByRole(), id: \.role) { group in
                                    AdminUserSection(
                                        roleLabel: group.role,
                                        users: group.users,
                                        onEdit: { user in editingUser = user },
                                        onDelete: { user in userPendingDeletion = user }
                                    )
                                }

                                if viewModel.users.isEmpty && !viewModel.isLoading {
                                    Text("No users yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 40)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
        .sheet(isPresented: $showInsertSheet) {
            AdminUserInsertView(viewModel: viewModel)
        }
        .sheet(item: $editingUser) { user in
            AdminUserUpdateView(viewModel: viewModel, user: user)
        }
        .alert(
            "Delete User \(userPendingDeletion?.name ?? "")?",
            isPresented: Binding(
                get: { userPendingDeletion != nil },
                set: { if !$0 { userPendingDeletion = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { userPendingDeletion = nil }
            Button("Confirm", role: .destructive) {
                if let user = userPendingDeletion {
                    viewModel.deleteUser(uid: user.id)
                }
                userPendingDeletion = nil
            }
        }
    }
}

private struct AdminUserSection: View {
    let roleLabel: String
    let users: [UserModel]
    let onEdit: (UserModel) -> Void
    let onDelete: (UserModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(roleLabel)
                .font(.subheadline)
                .bold()
                .foregroundColor(.black)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 4)

            ForEach(users) { user in
                HStack {
                    Button {
                        onEdit(user)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name.isEmpty ? "(no name)" : user.name)
                                .foregroundColor(.black)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)

                    Button {
                        onDelete(user)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                Divider()
            }
        }
    }
}

struct AdminUserUpdateView: View {

    @ObservedObject var viewModel: AdminUsersViewModel
    let user: UserModel

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isFormValid: Bool {
        !trimmedName.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Email") {
                    Text(user.email)
                        .foregroundColor(.gray)
                }
                Section("User Name") {
                    TextField("Write New User Name", text: $name)
                }

                Section {
                    Button {
                        viewModel.updateName(uid: user.id, newName: trimmedName)
                        dismiss()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .background(isFormValid ? Color.alpseOrange : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Update User \(user.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                name = user.name
            }
        }
    }
}

struct AdminUserInsertView: View {

    @ObservedObject var viewModel: AdminUsersViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var organization: String = ""
    @State private var role: String = "student"

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(trimmedEmail) &&
        password.count >= 6
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Username") {
                    TextField("Write New Username", text: $name)
                }
                Section("Email") {
                    TextField("user@alpse.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                    if !trimmedEmail.isEmpty && !isValidEmail(trimmedEmail) {
                        Text("Invalid email format.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                Section("Password") {
                    SecureField("At least 6 characters", text: $password)
                    if !password.isEmpty && password.count < 6 {
                        Text("Password must be at least 6 characters.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                Section("Role") {
                    Picker("Role", selection: $role) {
                        ForEach(AdminUsersViewModel.availableRoles, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("Organization / Faculty") {
                    TextField("Optional", text: $organization)
                }

                Section {
                    Button {
                        viewModel.createUser(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            email: trimmedEmail,
                            password: password,
                            role: role,
                            organization: organization
                        )
                        dismiss()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .background(isFormValid ? Color.alpseOrange : Color.gray)
                            .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Insert New User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
