//
//  AdminRoomsViewModel.swift
//  ALPSE
//

import Foundation
import Combine

class AdminRoomsViewModel: ObservableObject {

    @Published var rooms: [Room] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    private let repository = RoomRepository()

    func fetchRooms() {
        isLoading = true
        repository.fetchRooms { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let rooms):
                    self?.rooms = rooms.sorted { $0.name < $1.name }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func createRoom(name: String, capacity: Int, isFaculty: Bool, facultyName: String) {
        let room = Room(
            id: "",
            name: name,
            capacity: capacity,
            facultyRoom: isFaculty,
            facultyName: isFaculty ? facultyName : "",
            status: true
        )

        repository.createRoom(room: room) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchRooms()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func updateRoom(id: String, name: String, capacity: Int, isFaculty: Bool, facultyName: String) {
        let room = Room(
            id: id,
            name: name,
            capacity: capacity,
            facultyRoom: isFaculty,
            facultyName: isFaculty ? facultyName : "",
            status: true
        )

        repository.updateRoom(room: room) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchRooms()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteRoom(id: String) {
        repository.deleteRoom(roomId: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchRooms()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
