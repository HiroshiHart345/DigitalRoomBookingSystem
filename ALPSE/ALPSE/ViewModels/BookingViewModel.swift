//
//  BookingViewModel.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 28/05/26.
//

import Foundation
import FirebaseFirestore
import Combine

class BookingViewModel: ObservableObject {

    @Published var activityName = ""
    @Published var description = ""

    @Published var selectedDate = Date()
    @Published var startTime = Date()
    @Published var endTime = Date()

    @Published var successMessage = ""
    @Published var errorMessage = ""

    private let repository = BookingRepository()

    func submitBooking(room: Room, user: UserModel) {

        // ❌ validation
        if endTime <= startTime {
            errorMessage = "End time must be after start time"
            successMessage = ""
            return
        }

        let startDateTime = combine(date: selectedDate, time: startTime)
        let endDateTime = combine(date: selectedDate, time: endTime)

        let start = Timestamp(date: startDateTime)
        let end = Timestamp(date: endDateTime)

        let status = "Pending SA Approval"

        let booking = Booking(
            id: "",
            roomId: room.id,
            roomName: room.name,
            userId: user.id,
            userName: user.name,
            organization: user.organization,
            activityName: self.activityName,
            description: self.description,
            date: Timestamp(date: selectedDate),
            startTime: start,
            endTime: end,
            status: status,
            rejectionReason: "",
            createdAt: Timestamp(date: Date()),
            facultyName: room.facultyName
        )

        // 🔥 SINGLE SAFE CALL (NO MORE PRE-CHECK)
        repository.createBookingSafe(booking: booking) { [weak self] result in

            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {

                case .success:
                    self.successMessage = "Booking Submitted"
                    self.errorMessage = ""

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.successMessage = ""
                }
            }
        }
    }

    // MARK: combine date + time
    private func combine(date: Date, time: Date) -> Date {

        let calendar = Calendar.current

        let d = calendar.dateComponents([.year, .month, .day], from: date)
        let t = calendar.dateComponents([.hour, .minute], from: time)

        var components = DateComponents()

        components.year = d.year
        components.month = d.month
        components.day = d.day
        components.hour = t.hour
        components.minute = t.minute

        return calendar.date(from: components) ?? Date()
    }
}
