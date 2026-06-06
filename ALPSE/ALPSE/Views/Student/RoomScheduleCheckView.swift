//
//  RoomScheduleCheckView.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 01/06/26.
//

import SwiftUI
import FirebaseFirestore

struct RoomScheduleCheckView: View {
    let room: Room
    let user: UserModel
    
    @StateObject private var viewModel = AdminBookingsViewModel()
    
    @State private var selectedDate = Date()
    @State private var selectedSlots: [String] = []
    
    var generatedTimeSlots: [String] {
        var slots: [String] = []
        var currentMinutes = 5 * 60
        let endMinutes = 22 * 60
        while currentMinutes + 50 <= endMinutes {
            let start = String(format: "%02d.%02d", currentMinutes / 60, currentMinutes % 60)
            currentMinutes += 50
            let end = String(format: "%02d.%02d", currentMinutes / 60, currentMinutes % 60)
            slots.append("\(start) - \(end)")
        }
        return slots
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Date")
                    .font(.headline)
                Spacer()
                DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()
            Rectangle().fill(Color(UIColor.systemGroupedBackground)).frame(height: 8)
            
            List {
                ForEach(generatedTimeSlots, id: \.self) { slot in
                    let isBooked = isSlotBooked(slot)
                    let isSelected = selectedSlots.contains(slot)
                    
                    Button(action: { toggleSelection(slot, isBooked: isBooked) }) {
                        HStack {
                            // Teks Waktu
                            Text(slot)
                                .foregroundColor(isBooked ? .secondary : .primary)
                            
                            Spacer()
                            
                            // Indikator Status
                            if isBooked {
                                Text("Booked")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            } else if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.alpseOrange)
                                    .font(.title3)
                            } else {
                                Text("Available")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .disabled(isBooked || !isSelectable(slot))
                }
            }
            
            if !selectedSlots.isEmpty {
                NavigationLink(destination: BookingFormView(
                    user: user, room: room, selectedDate: selectedDate,
                    timeSlots: selectedSlots.sorted()
                )) {
                    Text("Book (\(selectedSlots.count) slot)")
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(Color.alpseOrange).foregroundColor(.white).cornerRadius(15)
                }
                .padding()
            }
        }
        .navigationTitle(room.name)
        .onAppear {
            viewModel.fetchRoomBookings(
                roomId: room.id,
                excluding: ""
            )
        }
        .onChange(of: selectedDate) {
            selectedSlots.removeAll()
        }
    }
    
    func isSelectable(_ slot: String) -> Bool {
        if selectedSlots.contains(slot) { return true }
        if selectedSlots.isEmpty { return true }
        
        guard let currentIndex = generatedTimeSlots.firstIndex(of: slot) else { return false }
        
        let selectedIndices = selectedSlots.compactMap { generatedTimeSlots.firstIndex(of: $0) }
        guard let minIndex = selectedIndices.min(), let maxIndex = selectedIndices.max() else { return true }
        
        return currentIndex == minIndex - 1 || currentIndex == maxIndex + 1
    }
    
    func toggleSelection(_ slot: String, isBooked: Bool) {
        if isBooked { return }
        if selectedSlots.contains(slot) { selectedSlots.removeAll { $0 == slot } }
        else { selectedSlots.append(slot) }
    }
    
    func isSlotBooked(_ slot: String) -> Bool {
        
        let calendar = Calendar.current
        
        let bookingsOnDate = viewModel.roomBookings.filter { booking in
            
            calendar.isDate(
                booking.date.dateValue(),
                inSameDayAs: selectedDate
            )
            &&
            !booking.status.contains("Rejected")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        
        let parts = slot.components(separatedBy: " - ")
        
        guard
            let slotStartTime = formatter.date(from: parts[0]),
            let slotEndTime = formatter.date(from: parts[1])
        else {
            return false
        }
        
        return bookingsOnDate.contains { booking in
            
            let bookingStart =
            formatter.date(
                from: formatter.string(
                    from: booking.startTime.dateValue()
                )
            )!
            
            let bookingEnd =
            formatter.date(
                from: formatter.string(
                    from: booking.endTime.dateValue()
                )
            )!
            
            return slotStartTime < bookingEnd &&
            slotEndTime > bookingStart
        }
    }
    
}
