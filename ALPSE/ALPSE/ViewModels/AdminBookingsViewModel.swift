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

    private let repository = BookingRepository()

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
        accepted: Bool,
        reason: String
    ) {
        let status = accepted ? "Approved" : "Rejected"

        repository.adminUpdateBooking(
            bookingId: id,
            date: Timestamp(date: date),
            startTime: Timestamp(date: startTime),
            endTime: Timestamp(date: endTime),
            status: status,
            rejectionReason: accepted ? "" : reason
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
