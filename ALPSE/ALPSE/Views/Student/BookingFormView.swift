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
    let selectedDate: Date
    let timeSlots: [String]
    
    @StateObject private var viewModel = BookingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !viewModel.activityName.isEmpty && !viewModel.description.isEmpty && !timeSlots.isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Schedule")) {
                LabeledContent("Room", value: room.name)
                LabeledContent("Date", value: selectedDate.formatted(date: .long, time: .omitted))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Time Slots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(timeSlots, id: \.self) { slot in
                        Text(slot)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 2)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Details")) {
                TextField("Activity Name", text: $viewModel.activityName)
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 120)
                }
            }
        }
        .navigationTitle("Confirm Booking")
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.submitMultiSlotBooking(
                        room: room,
                        user: user,
                        date: selectedDate,
                        slots: timeSlots,
                        onSuccess: {
                            dismiss()
                        }
                    )
                }) {
                    Text("Submit Booking")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.alpseOrange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .disabled(!isFormValid)
                .padding(.horizontal)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage).foregroundColor(.red).font(.caption)
                }
            }
            .background(.regularMaterial)
        }
    }
}
