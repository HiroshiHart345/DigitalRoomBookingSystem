//
//  BookingRepository.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import FirebaseFirestore

class BookingRepository {

    private let db = Firestore.firestore()

    func createBookingSafe(
        booking: Booking,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let roomId = booking.roomId
        let newStart = booking.startTime.dateValue()
        let newEnd = booking.endTime.dateValue()

        let bookingsRef = db.collection("bookings")

        bookingsRef
            .whereField("roomId", isEqualTo: roomId)
            .getDocuments { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success(()))
                    return
                }

                for doc in documents {

                    let data = doc.data()

                    guard
                        let existingStart = (data["startTime"] as? Timestamp)?.dateValue(),
                        let existingEnd = (data["endTime"] as? Timestamp)?.dateValue()
                    else { continue }

                    let overlap = newStart < existingEnd && newEnd > existingStart

                    if overlap {
                        let error = NSError(
                            domain: "BookingError",
                            code: 1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Room already booked at this time"
                            ]
                        )
                        completion(.failure(error))
                        return
                    }
                }

                bookingsRef.addDocument(data: [
                    "roomId": booking.roomId,
                    "roomName": booking.roomName,

                    "userId": booking.userId,
                    "userName": booking.userName,

                    "organization": booking.organization,

                    "activityName": booking.activityName,
                    "description": booking.description,

                    "date": booking.date,
                    "startTime": booking.startTime,
                    "endTime": booking.endTime,

                    "status": booking.status,
                    "rejectionReason": booking.rejectionReason,

                    "createdAt": booking.createdAt,

                    "facultyName": booking.facultyName
                ]) { error in

                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }

    func fetchUserBookings(
        userId: String,
        completion: @escaping (Result<[Booking], Error>) -> Void
    ) {

        db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let bookings = documents.map { doc in
                    let data = doc.data()

                    return Booking(
                        id: doc.documentID,
                        roomId: data["roomId"] as? String ?? "",
                        roomName: data["roomName"] as? String ?? "",
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

                completion(.success(bookings))
            }
    }
    
    /// Function for fetching data based on its pending status
    func fetchPendingBookings(forStatus status: String, faculty: String? = nil, completion: @escaping (Result<[Booking], Error>) -> Void) {
        var query: Query = db.collection("bookings").whereField("status", isEqualTo: status)
        
        // Jika ada parameter faculty (khusus untuk Academic Support), lakukan filtering
        if let faculty = faculty, !faculty.isEmpty {
            query = query.whereField("facultyName", isEqualTo: faculty)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            let bookings = documents.map { doc in
                let data = doc.data()
                return Booking(
                    id: doc.documentID,
                    roomId: data["roomId"] as? String ?? "",
                    roomName: data["roomName"] as? String ?? "",
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
            completion(.success(bookings))
        }
    }
    
    /// Function for updating status approve or reject
    func updateBookingStatus(bookingId: String, newStatus: String, rejectionReason: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        var updateData: [String: Any] = ["status": newStatus]
        if !rejectionReason.isEmpty {
            updateData["rejectionReason"] = rejectionReason
        }
        
        db.collection("bookings")
            .document(bookingId)
            .updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
