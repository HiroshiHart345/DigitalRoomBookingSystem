//
//  Room.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation

struct Room: Identifiable, Codable {

    var id: String
    var name: String
    var capacity: Int
    var facultyRoom: Bool
    var facultyName: String
    var status: Bool

}
