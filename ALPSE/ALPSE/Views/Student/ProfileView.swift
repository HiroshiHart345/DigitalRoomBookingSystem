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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.alpseOrange)
                        .background(Circle().fill(Color(UIColor.systemGray6)))
                    
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .padding(.bottom, 10)
                
                Section {
                    LabeledContent {
                        Text(user.email).foregroundColor(.alpseOrange)
                    } label: { Text("Email") }
                    
                    LabeledContent {
                        Text(user.role.capitalized).foregroundColor(.alpseOrange)
                    } label: { Text("Role") }
                    
                    LabeledContent {
                        Text(user.organization).foregroundColor(.alpseOrange)
                    } label: { Text("Organization") }
                }
                
                Section {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.alpseOrange)
                            .font(.title2)
                    }
                }
            }
        }
    }
}
