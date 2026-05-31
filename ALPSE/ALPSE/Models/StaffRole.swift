//
//  StaffRole.swift
//  ALPSE
//
//  Created by Evelin Alim Natadjaja on 30/05/26.
//

import Foundation

enum StaffRole: String {
    case studentAffairs = "Student Affairs"
    case academicSupport = "Academic Support"
    case propertyManagement = "Property Management"
    
    var targetPendingStatus: String {
        switch self {
        case .studentAffairs: return "Pending SA Approval"
        case .academicSupport: return "Pending AS Approval"
        case .propertyManagement: return "Pending PM Approval"
        }
    }
}
