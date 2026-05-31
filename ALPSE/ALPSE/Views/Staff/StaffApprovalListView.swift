//
//  StaffApprovalListView.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 30/05/26.
//

import SwiftUI

struct StaffApprovalListView: View {
    @ObservedObject var viewModel: ApprovalViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.pendingBookings) { booking in
                NavigationLink(destination: StaffApprovalDetailView(booking: booking, viewModel: viewModel)) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(booking.roomName)
                                .font(.headline)
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                Text("Capacity: \(booking.roomCapacity)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        if !booking.facultyName.isEmpty && booking.facultyName != "Umum" {
                            Text("Faculty Room")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Not Faculty Room")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Need \(viewModel.currentRole.rawValue) Approval")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadPendingBookings()
            }
            .overlay(Group {
                if viewModel.pendingBookings.isEmpty {
                    Text("No Pending Approvals")
                        .foregroundColor(.gray)
                }
            })
        }
    }
}
