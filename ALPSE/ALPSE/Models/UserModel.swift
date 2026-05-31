//
//  UserModel.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 31/05/26.
//


import Foundation

struct UserModel: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var email: String
    var role: String
    var organization: String
}
