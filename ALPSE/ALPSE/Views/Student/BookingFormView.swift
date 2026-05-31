//
//  BookingFormView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import SwiftUI

struct BookingFormView: View {

    let user: UserModel
    let room: Room

    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = BookingViewModel()

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                Text(room.name)
                    .font(.largeTitle)
                    .bold()

                DatePicker(
                    "Booking Date",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date]
                )

                DatePicker(
                    "Start Time",
                    selection: $viewModel.startTime,
                    displayedComponents: [.hourAndMinute]
                )

                DatePicker(
                    "End Time",
                    selection: $viewModel.endTime,
                    displayedComponents: [.hourAndMinute]
                )

                TextField("Activity Name", text: $viewModel.activityName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)

                TextField("Description", text: $viewModel.description)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)

                Button {
                    viewModel.submitBooking(room: room, user: user)
                } label: {
                    Text("SUBMIT BOOKING")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.alpseOrange)
                        .cornerRadius(15)
                }

                Text(viewModel.successMessage)
                    .foregroundColor(.green)

                Text(viewModel.errorMessage)
                    .foregroundColor(.red)

            }
            .padding()
            
        }
        .background(Color(.systemGray6))
        
    }
    
}
