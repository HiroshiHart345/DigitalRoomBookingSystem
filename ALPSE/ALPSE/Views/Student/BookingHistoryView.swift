//
//  BookingHistoryView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 28/05/26.
//

import SwiftUI
import FirebaseFirestore

enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case finished = "Finished"
}

struct BookingHistoryView: View {
    let user: UserModel
    @State private var bookings: [Booking] = []
    @State private var selectedFilter: HistoryFilter = .all
    @State private var showProfileSheet = false
    
    var filteredBookings: [Booking] {
        switch selectedFilter {
        case .all: return bookings
        case .pending: return bookings.filter { $0.status.contains("Pending") }
        case .finished: return bookings.filter { $0.status == "Approved" || $0.status.contains("Rejected") }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("Bookings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Button {
                        showProfileSheet = true
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.alpseOrange)
                            .font(.system(size: 44))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 10)
                .background(Color(UIColor.systemBackground))
                .padding(.vertical, 15)
                
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(HistoryFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .background(Color(UIColor.systemBackground))
                
                List {
                    if filteredBookings.isEmpty {
                        Text("No Booking Made Yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredBookings) { booking in
                            NavigationLink {
                                BookingDetailView(booking: booking)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(booking.roomName)
                                        .font(.headline)
                                    Text(booking.activityName)
                                        .font(.subheadline)
                                    Text(booking.status)
                                        .font(.caption)
                                        .foregroundColor(statusTextColor(for: booking.status))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationBarHidden(true)
            
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    NavigationLink(destination: RoomListView(user: user)) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.alpseOrange)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 10)
                }
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileView(user: user)
            }
            .onAppear {
                fetchBookings()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func statusTextColor(for status: String) -> Color {
        if status.contains("Pending") { return .alpseOrange }
        if status == "Approved" { return .green }
        if status.contains("Rejected") { return .red }
        return .gray
    }
    
    func fetchBookings() {
        Firestore.firestore()
            .collection("bookings")
            .whereField("userId", isEqualTo: user.id)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                bookings = documents.compactMap { doc in
                    let data = doc.data()
                    return Booking(
                        id: doc.documentID,
                        roomId: data["roomId"] as? String ?? "",
                        roomName: data["roomName"] as? String ?? "",
                        roomCapacity: data["roomCapacity"] as? Int ?? 0,
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
            }
    }
}

