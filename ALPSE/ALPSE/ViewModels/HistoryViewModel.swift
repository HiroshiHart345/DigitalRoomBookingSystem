//
//  HistoryViewModel.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import Combine

class HistoryViewModel: ObservableObject {

    @Published var bookings: [Booking] = []

    private let repository = BookingRepository()

    func fetchBookings(
        userId: String
    ) {

        repository.fetchUserBookings(
            userId: userId
        ) { [weak self] result in

            DispatchQueue.main.async {

                switch result {

                case .success(let bookings):

                    self?.bookings = bookings

                case .failure(let error):

                    print(error.localizedDescription)

                }

            }

        }

    }

}
