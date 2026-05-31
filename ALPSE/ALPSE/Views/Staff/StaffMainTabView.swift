//
//  StaffMainTabView.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 30/05/26.
//

import SwiftUI

struct StaffMainTabView: View {
    let user: UserModel
    @StateObject private var viewModel: ApprovalViewModel
    @State private var selectedTab = 0
    
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
        TabView(selection: $selectedTab) {
            
            // Tab 1: Home
            StaffHomeView(user: user, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: Approval List
            StaffApprovalListView(viewModel: viewModel)
                .tabItem {
                    Label("Approval", systemImage: "checkmark.seal.fill")
                }
                .tag(1)
            
            // Tab 3: Profile
            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(.alpseOrange)
    }
}

import SwiftUI
import FirebaseFirestore

// MARK: - PREVIEW MOCKS & DATA
extension ApprovalViewModel {
    static var mockForPreview: ApprovalViewModel {
        let vm = ApprovalViewModel(role: .studentAffairs, faculty: "Student Affairs")
        
        vm.pendingBookings = [
            Booking(
                id: "b1", roomId: "r505", roomName: "Room 505",
                userId: "u1", userName: "Evelin", organization: "BEM",
                activityName: "Rapat Rutin", description: "Rapat BEM Mingguan",
                date: Timestamp(date: Date()), startTime: Timestamp(date: Date()), endTime: Timestamp(date: Date().addingTimeInterval(3600)),
                status: "Pending SA Approval", rejectionReason: "", createdAt: Timestamp(date: Date()), facultyName: "Informatics"
            ),
            Booking(
                id: "b2", roomId: "r506", roomName: "Room 506",
                userId: "u2", userName: "Sharon Natalie Sutanto", organization: "UKM Basket",
                activityName: "Gladi Resik", description: "Gladi Resik Untuk Pertunjukan Basket",
                date: Timestamp(date: Date()), startTime: Timestamp(date: Date()), endTime: Timestamp(date: Date().addingTimeInterval(7200)),
                status: "Pending SA Approval", rejectionReason: "", createdAt: Timestamp(date: Date()), facultyName: "Informatics"
            ),
            Booking(
                id: "b3", roomId: "raud", roomName: "Auditorium",
                userId: "u3", userName: "Hiroshi", organization: "UKM Musik",
                activityName: "Konser Akhir Tahun", description: "Konser besar",
                date: Timestamp(date: Date()), startTime: Timestamp(date: Date()), endTime: Timestamp(date: Date().addingTimeInterval(14400)),
                status: "Pending SA Approval", rejectionReason: "", createdAt: Timestamp(date: Date()), facultyName: "Umum"
            )
            
        ]
        return vm
    }
}

let dummyStaffUser = UserModel(
    id: "staff1",
    name: "Student Affairs' Name",
    email: "sa@uc.ac.id",
    role: "Student Affairs",
    organization: "Student Affairs"
)

// MARK: - PREVIEWS CANVAS XCODE

#Preview("1. Home Dashboard") {
    struct PreviewWrapper: View {
        @State var tab = 0
        var body: some View {
            StaffHomeView(user: dummyStaffUser, selectedTab: $tab)
        }
    }
    return PreviewWrapper()
}

#Preview("2. Approval List Page") {
    StaffApprovalListView(viewModel: .mockForPreview)
}

#Preview("3. Approval Detail Page (Room 506)") {
    let room506Booking = ApprovalViewModel.mockForPreview.pendingBookings[1]
    
    return NavigationStack {
        StaffApprovalDetailView(
            booking: room506Booking,
            viewModel: .mockForPreview
        )
    }
}

#Preview("4. Full Tab View Flow") {
    StaffMainTabView(user: dummyStaffUser)
    // Notes: In this preview, list is using data from Firestore not dummy.
}
