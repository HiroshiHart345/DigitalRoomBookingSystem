//
//  RoomRepository.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import FirebaseFirestore

class RoomRepository {

    private let db = Firestore.firestore()

    func fetchRooms(
        completion: @escaping(Result<[Room], Error>) -> Void
    ) {

        db.collection("rooms")
            .getDocuments { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let rooms = documents.map { doc in

                    let data = doc.data()

                    return Room(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        capacity: data["capacity"] as? Int ?? 0,
                        facultyRoom: data["facultyRoom"] as? Bool ?? false,
                        facultyName: data["facultyName"] as? String ?? "",
                        status: data["status"] as? Bool ?? true
                    )

                }

                completion(.success(rooms))

            }

    }

    func createRoom(
        room: Room,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let data: [String: Any] = [
            "name": room.name,
            "capacity": room.capacity,
            "facultyRoom": room.facultyRoom,
            "facultyName": room.facultyName,
            "status": room.status
        ]

        db.collection("rooms")
            .addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func updateRoom(
        room: Room,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let data: [String: Any] = [
            "name": room.name,
            "capacity": room.capacity,
            "facultyRoom": room.facultyRoom,
            "facultyName": room.facultyName,
            "status": room.status
        ]

        db.collection("rooms")
            .document(room.id)
            .setData(data, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func deleteRoom(
        roomId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        db.collection("rooms")
            .document(roomId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

}
