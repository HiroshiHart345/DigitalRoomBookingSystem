//
//  ApprovalViewModel.swift
//  
//
//  Created by Evelin Alim Natadjaja on 31/05/26.
//


import Foundation
import Combine

class ApprovalViewModel: ObservableObject {
    @Published var pendingBookings: [Booking] = []
    @Published var errorMessage = ""
    
    private let repository = BookingRepository()
    let currentRole: StaffRole
    let staffFaculty: String
    
    init(role: StaffRole, faculty: String) {
        self.currentRole = role
        self.staffFaculty = faculty
    }
    
    func loadPendingBookings() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        
        let targetStatus = currentRole.targetPendingStatus
        let facultyFilter = (currentRole == .academicSupport) ? staffFaculty : nil
        
        repository.fetchPendingBookings(forStatus: targetStatus, faculty: facultyFilter) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookings):
                    self?.pendingBookings = bookings
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func handleApproval(booking: Booking, isApproved: Bool, reason: String = "") {
        var nextStatus = ""
        
        if isApproved {
            switch currentRole {
            case .studentAffairs:
                if !booking.facultyName.isEmpty && booking.facultyName != "Umum" {
                    nextStatus = "Pending AS Approval"
                } else {
                    nextStatus = "Pending PM Approval"
                }
                
            case .academicSupport:
                nextStatus = "Pending PM Approval"
                
            case .propertyManagement:
                nextStatus = "Approved"
            }
        } else {
            nextStatus = "Rejected by \(currentRole.rawValue)"
        }
        
        repository.updateBookingStatus(bookingId: booking.id, newStatus: nextStatus, rejectionReason: reason) { [weak self] result in
            DispatchQueue.main.async {
                if case .success = result {
                    self?.loadPendingBookings()
                }
            }
        }
    }
}
