//
//  StaffApprovalDetailView.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 30/05/26.
//

import SwiftUI
import FirebaseFirestore

struct StaffApprovalDetailView: View {
    let booking: Booking
    @ObservedObject var viewModel: ApprovalViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showRejectionSheet = false
    @State private var rejectionReason = ""

    func formatDate(_ timestamp: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp.dateValue())
    }

    func formatTime(_ timestamp: Timestamp) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp.dateValue())
    }

    var body: some View {
        Form {
            Section(header: Text("Schedule & Room")) {
                LabeledContent("Room", value: booking.roomName)
                LabeledContent("Date", value: formatDate(booking.date))
                LabeledContent("Time", value: "\(formatTime(booking.startTime)) - \(formatTime(booking.endTime))")
            }
            
            Section(header: Text("Activity Details")) {
                LabeledContent("Program", value: booking.activityName)
                LabeledContent("Organization", value: booking.organization)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .foregroundColor(.secondary)
                    Text(booking.description)
                        .padding(.top, 2)
                }
            }
        }
        .navigationTitle(booking.roomName)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - ACTION BUTTONS (FLOATING AT BOTTOM)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 16) {
                Button(action: {
                    showRejectionSheet = true
                }) {
                    Text("Reject")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.orange)
                        .cornerRadius(15)
                }

                Button(action: {
                    viewModel.handleApproval(booking: booking, isApproved: true)
                    dismiss()
                }) {
                    Text("Approve")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.alpseOrange)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
            .padding()
            .background(.regularMaterial)
        }
        // MARK: - REJECTION MODAL
        .sheet(isPresented: $showRejectionSheet) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Reason for Refusal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $rejectionReason)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    Spacer()
                    
                    Button("Submit") {
                        viewModel.handleApproval(booking: booking, isApproved: false, reason: rejectionReason)
                        showRejectionSheet = false
                        dismiss()
                    }
                    .disabled(rejectionReason.isEmpty)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(rejectionReason.isEmpty ? Color.gray : Color.alpseOrange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .navigationTitle("Reject Booking")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showRejectionSheet = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.alpseOrange)
                                .font(.title2)
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.45)])
        }
    }
    
    private func statusColor(for status: String) -> Color {
        if status.contains("Pending") { return .orange }
        if status == "Approved" { return .green }
        if status.contains("Rejected") { return .red }
        return .gray
    }
}
