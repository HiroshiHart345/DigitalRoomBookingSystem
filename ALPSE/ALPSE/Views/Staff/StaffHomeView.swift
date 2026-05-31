//
//  StaffHomeView.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 30/05/26.
//

import SwiftUI

struct StaffHomeView: View {
    let user: UserModel
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Welcome Back,")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(user.name)
                            .font(.title2)
                            .bold()
                        Text(user.role)
                            .font(.caption)
                            .foregroundColor(.alpseOrange)
                    }
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    selectedTab = 1
                }) {
                    VStack(spacing: 15) {
                        Text("Approval")
                            .font(.headline)
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(Color.alpseOrange)
                    .cornerRadius(25)
                    .shadow(radius: 5)
                }
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}
