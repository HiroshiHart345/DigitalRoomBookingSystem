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
    
    @Published var successMessage = ""
    @Published var errorMessage = ""
    
    private let repository = BookingRepository()
    
    func submitBooking(room: Room, user: UserModel, selectedDate: Date, timeSlot: String) {
        let timeComponents = timeSlot.components(separatedBy: " - ")
        guard timeComponents.count == 2 else {
            self.errorMessage = "Format waktu tidak valid."
            return
        }
        
        let startTimeString = timeComponents[0]
        let endTimeString = timeComponents[1]
        
        guard let startDateTime = combineDateWithTimeString(date: selectedDate, timeString: startTimeString),
              let endDateTime = combineDateWithTimeString(date: selectedDate, timeString: endTimeString) else {
            self.errorMessage = "Gagal memproses kalkulasi waktu."
            return
        }
        
        if endDateTime <= startDateTime {
            errorMessage = "Waktu selesai harus lebih besar dari waktu mulai."
            successMessage = ""
            return
        }
        
        let start = Timestamp(date: startDateTime)
        let end = Timestamp(date: endDateTime)
        let status = "Pending SA Approval"
        
        let booking = Booking(
            id: "",
            roomId: room.id,
            roomName: room.name,
            roomCapacity: room.capacity,
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
    
    // MARK: - Helper Function
    private func combineDateWithTimeString(date: Date, timeString: String) -> Date? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH.mm" // Sesuaikan dengan format string di UI-mu
        
        guard let timeDate = timeFormatter.date(from: timeString) else {
            return nil
        }
        
        let calendar = Calendar.current
        let d = calendar.dateComponents([.year, .month, .day], from: date)
        let t = calendar.dateComponents([.hour, .minute], from: timeDate)
        
        var components = DateComponents()
        components.year = d.year
        components.month = d.month
        components.day = d.day
        components.hour = t.hour
        components.minute = t.minute
        
        return calendar.date(from: components)
    }
    
    func submitMultiSlotBooking(room: Room, user: UserModel, date: Date, slots: [String], onSuccess: @escaping () -> Void) {
        guard !activityName.isEmpty && !description.isEmpty else {
            self.errorMessage = "Mohon isi semua kolom!"
            return
        }
        
        let firstSlot = slots.first!.components(separatedBy: " - ")[0]
        let lastSlot = slots.last!.components(separatedBy: " - ")[1]
        
        let startDateTime = combine(date: date, timeString: firstSlot)
        let endDateTime = combine(date: date, timeString: lastSlot)
        
        let booking = Booking(
            id: "",
            roomId: room.id,
            roomName: room.name,
            roomCapacity: room.capacity,
            userId: user.id,
            userName: user.name,
            organization: user.organization,
            activityName: self.activityName,
            description: self.description,
            date: Timestamp(date: date),
            startTime: Timestamp(date: startDateTime),
            endTime: Timestamp(date: endDateTime),
            status: "Pending SA Approval",
            rejectionReason: "",
            createdAt: Timestamp(date: Date()),
            facultyName: room.facultyName
        )
        
        repository.createBookingSafe(booking: booking) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Booking Submitted"
                    onSuccess() // 💡 Sinyal balik untuk dismiss halaman
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func combine(date: Date, timeString: String) -> Date {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH.mm"
        
        guard let timeDate = timeFormatter.date(from: timeString) else { return date }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
        
        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        
        return calendar.date(from: components) ?? date
    }
}
