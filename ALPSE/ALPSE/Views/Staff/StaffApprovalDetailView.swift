//
//  StaffApprovalDetailView.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 30/05/26.
//

import SwiftUI
import FirebaseCore

struct StaffApprovalDetailView: View {
    let booking: Booking
    @ObservedObject var viewModel: ApprovalViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showRejectionSheet = false
    @State private var rejectionReason = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(booking.roomName)
                        .font(.title2)
                        .bold()
                    Text(booking.date.dateValue().formatted(date: .complete, time: .omitted))
                    Text("\(booking.startTime.dateValue().formatted(date: .omitted, time: .shortened)) - \(booking.endTime.dateValue().formatted(date: .omitted, time: .shortened))")
                }
                
                Divider()
                
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 15) {
                    GridRow {
                        Text("Program's Name").foregroundColor(.gray)
                        Text(": \(booking.activityName)")
                    }
                    GridRow {
                        Text("Organizer").foregroundColor(.gray)
                        Text(": \(booking.organization)")
                    }
                    GridRow {
                        Text("Person In Charge").foregroundColor(.gray)
                        Text(": \(booking.userName)")
                    }
                    GridRow {
                        Text("Description").foregroundColor(.gray)
                        Text(": \(booking.description)")
                    }
                }
                
                Spacer(minLength: 40)
                
                HStack(spacing: 40) {
                    Button(action: {
                        viewModel.handleApproval(booking: booking, isApproved: true)
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        showRejectionSheet = true
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Update Booking Status")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRejectionSheet) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Rejected By \(viewModel.currentRole.rawValue)")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading) {
                        Text("Reason For Refusal :")
                            .font(.subheadline)
                        
                        TextEditor(text: $rejectionReason)
                            .frame(height: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Button("SUBMIT") {
                        viewModel.handleApproval(booking: booking, isApproved: false, reason: rejectionReason)
                        showRejectionSheet = false
                        dismiss()
                    }
                    .disabled(rejectionReason.isEmpty)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(rejectionReason.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Rejection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") { showRejectionSheet = false }
                    }
                }
            }
            .presentationDetents([.fraction(0.6)])
        }
    }
}
