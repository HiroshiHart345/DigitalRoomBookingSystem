//
//  StaffApprovalListView.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 30/05/26.
//

import SwiftUI

struct StaffApprovalListView: View {
    let user: UserModel
    @StateObject private var viewModel: ApprovalViewModel
    @State private var selectedTab = 0
    @State private var showProfileSheet = false
    
    init(user: UserModel) {
        self.user = user
        let normalizedRole = user.role.lowercased()
        let role: StaffRole
        if normalizedRole.contains("academic") {
            role = .academicSupport
        } else if normalizedRole.contains("property") {
            role = .propertyManagement
        } else {
            role = .studentAffairs
        }
        
        _viewModel = StateObject(wrappedValue: ApprovalViewModel(role: role, faculty: user.organization))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("Approval")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Button { showProfileSheet = true } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.alpseOrange)
                            .font(.system(size: 44))
                    }
                }
                .padding(20)
                .background(Color(UIColor.systemBackground))
                
                List(viewModel.pendingBookings) { booking in
                    NavigationLink(destination: StaffApprovalDetailView(booking: booking, viewModel: viewModel)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(booking.roomName).font(.headline)
                                Text(booking.activityName).font(.subheadline).foregroundColor(.secondary)
                                Text(booking.facultyName == "" ? "Not faculty room" : "Faculty room")
                                    .font(.caption)
                                    .foregroundColor(booking.facultyName == "" ? .red : .green)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfileSheet) { ProfileView(user: user) }
            .onAppear { viewModel.loadPendingBookings() }
        }
    }
}
