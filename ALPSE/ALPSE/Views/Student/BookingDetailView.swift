//
//  BookingDetailView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 28/05/26.
//

import SwiftUI
import FirebaseFirestore

struct BookingDetailView: View {
    let booking: Booking

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
            
            Section(header: Text("Approval Status")) {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(booking.status)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor(for: booking.status))
                        .clipShape(Capsule())
                }
                
                if !booking.rejectionReason.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rejection Reason")
                            .foregroundColor(.secondary)
                        Text(booking.rejectionReason)
                            .foregroundColor(.red)
                            .padding(.top, 2)
                    }
                }
            }
        }
        .navigationTitle(booking.roomName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func statusColor(for status: String) -> Color {
        if status.contains("Pending") { return .orange }
        if status == "Approved" { return .green }
        if status.contains("Rejected") { return .red }
        return .gray
    }
}
