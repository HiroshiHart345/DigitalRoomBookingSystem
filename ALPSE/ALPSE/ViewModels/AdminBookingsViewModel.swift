//
//  AdminBookingsViewModel.swift
//  ALPSE
//

import Foundation
import Combine
import FirebaseFirestore

class AdminBookingsViewModel: ObservableObject {

    @Published var bookings: [Booking] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    /// Per-room conflict bookings (fetched on demand for the update sheet).
    @Published var roomBookings: [Booking] = []

    private let repository = BookingRepository()

    func fetchRoomBookings(roomId: String, excluding bookingId: String) {
        repository.fetchBookingsForRoom(roomId: roomId, excludingBookingId: bookingId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookings):
                    self?.roomBookings = bookings
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchBookings() {
        isLoading = true
        repository.fetchAllBookings { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let bookings):
                    self?.bookings = bookings
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteBooking(id: String) {
        repository.deleteBooking(bookingId: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchBookings()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func updateBooking(
        id: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        status: String,
        reason: String
    ) {
        let finalReason = status == "Rejected" ? reason : ""

        repository.adminUpdateBooking(
            bookingId: id,
            date: Timestamp(date: date),
            startTime: Timestamp(date: startTime),
            endTime: Timestamp(date: endTime),
            status: status,
            rejectionReason: finalReason
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchBookings()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
