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

        ZStack {

            Color.alpseOrange
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {

                Text(booking.roomName)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Text(formatDate(booking.date))
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(formatTime(booking.startTime)) - \(formatTime(booking.endTime))")
                    .font(.headline)
                    .foregroundColor(.white)

                Rectangle()
                    .fill(Color.white.opacity(0.8))
                    .frame(height: 1)
                    .padding(.vertical, 5)

                Text("Program's Name :   \(booking.activityName)")
                    .foregroundColor(.white)
                
                Text("Description          : ")
                    .foregroundColor(.white)

                Text(booking.description)
                    .foregroundColor(.white)

                Text(booking.status)
                    .fontWeight(.bold)
                    .foregroundColor(.alpseOrange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(10)

                if !booking.rejectionReason.isEmpty {

                    Text("Reason:")
                        .bold()
                        .foregroundColor(.white)

                    Text(booking.rejectionReason)
                        .foregroundColor(.red)

                }

                Spacer()

            }
            .padding()

        }

    }

}
