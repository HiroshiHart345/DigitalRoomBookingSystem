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

}
