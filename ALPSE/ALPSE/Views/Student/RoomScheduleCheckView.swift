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
    
    @State private var selectedDate = Date()
    @State private var allRoomBookings: [Booking] = []
    @State private var selectedSlots: [String] = [] // Menggunakan Array agar urut
    
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
                    .disabled(isBooked || !isSelectable(slot)) // Tetap tidak bisa klik jika booked
                }
            }
            
            if !selectedSlots.isEmpty {
                NavigationLink(destination: BookingFormView(
                    user: user, room: room, selectedDate: selectedDate,
                    timeSlots: selectedSlots.sorted()
                )) {
                    Text("Lanjut (\(selectedSlots.count) slot)")
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(Color.alpseOrange).foregroundColor(.white).cornerRadius(15)
                }
                .padding()
            }
        }
        .navigationTitle(room.name)
        .onAppear { fetchBookings() }
        .onChange(of: selectedDate) {
            selectedSlots.removeAll()
        }
    }
    
    

    // LOGIKA SELECTION
    func isSelectable(_ slot: String) -> Bool {
            // JIKA sudah dipilih, kita HARUS mengizinkan klik (untuk unselect)
            if selectedSlots.contains(slot) { return true }
            
            // JIKA belum dipilih, baru kita lakukan validasi urutan
            if selectedSlots.isEmpty { return true }
            
            guard let currentIndex = generatedTimeSlots.firstIndex(of: slot) else { return false }
            
            let selectedIndices = selectedSlots.compactMap { generatedTimeSlots.firstIndex(of: $0) }
            guard let minIndex = selectedIndices.min(), let maxIndex = selectedIndices.max() else { return true }
            
            // Izinkan jika slot bersebelahan dengan rentang yang sudah dipilih
            return currentIndex == minIndex - 1 || currentIndex == maxIndex + 1
        }

    func toggleSelection(_ slot: String, isBooked: Bool) {
        if isBooked { return }
        if selectedSlots.contains(slot) { selectedSlots.removeAll { $0 == slot } }
        else { selectedSlots.append(slot) }
    }

    func isSlotBooked(_ slot: String) -> Bool {

        let calendar = Calendar.current

        let bookingsOnDate = allRoomBookings.filter { booking in

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
    
    
    // MARK: - QUERY FIREBASE
    func fetchBookings() {
        Firestore.firestore()
            .collection("bookings")
            .whereField("roomId", isEqualTo: room.id) // Tarik semua jadwal untuk ruangan ini saja
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                // Parsing data Firestore ke array model Booking
                self.allRoomBookings = documents.compactMap { doc in
                    let data = doc.data()
                    return Booking(
                        id: doc.documentID,
                        roomId: data["roomId"] as? String ?? "",
                        roomName: data["roomName"] as? String ?? "",
                        roomCapacity: data["roomCapacity"] as? Int ?? 0,
                        userId: data["userId"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        organization: data["organization"] as? String ?? "",
                        activityName: data["activityName"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        date: data["date"] as? Timestamp ?? Timestamp(),
                        startTime: data["startTime"] as? Timestamp ?? Timestamp(),
                        endTime: data["endTime"] as? Timestamp ?? Timestamp(),
                        status: data["status"] as? String ?? "",
                        rejectionReason: data["rejectionReason"] as? String ?? "",
                        createdAt: data["createdAt"] as? Timestamp ?? Timestamp(),
                        facultyName: data["facultyName"] as? String ?? ""
                    )
                }
            }
    }
}
