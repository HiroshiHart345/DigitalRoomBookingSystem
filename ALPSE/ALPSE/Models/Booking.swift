//
//  Booking.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation
import FirebaseFirestore

struct Booking: Identifiable, Codable {
    
    var id: String
    
    var roomId: String
    var roomName: String
    var roomCapacity: Int
    
    var userId: String
    var userName: String
    
    var organization: String
    
    var activityName: String
    var description: String
    
    var date: Timestamp
    
    var startTime: Timestamp
    var endTime: Timestamp
    
    var status: String
    var rejectionReason: String
    
    var createdAt: Timestamp
    
    var facultyName: String
}
