//
//  RoomViewModel.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 28/05/26.
//


import Foundation
import Combine

class RoomViewModel: ObservableObject {

    @Published var rooms: [Room] = []

    private let repository = RoomRepository()

    func fetchRooms() {

        repository.fetchRooms { [weak self] result in

            DispatchQueue.main.async {

                switch result {

                case .success(let rooms):

                    self?.rooms = rooms

                case .failure(let error):

                    print(error.localizedDescription)

                }

            }

        }

    }

}
