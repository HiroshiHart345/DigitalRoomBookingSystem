//
//  RoomListView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 28/05/26.
//

import SwiftUI
import FirebaseFirestore

struct RoomListView: View {
    let user: UserModel
    @State private var rooms: [Room] = []

    var body: some View {
        List {
            ForEach(rooms) { room in
                NavigationLink {
                    RoomScheduleCheckView(room: room, user: user)
                } label: {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(room.name)
                            .font(.headline)
                        
                        HStack {
                            Text("Capacity: \(room.capacity)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if room.facultyRoom {
                                Text("• \(room.facultyName)")
                                    .font(.subheadline)
                                    .foregroundColor(.alpseOrange)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Rooms")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchRooms()
        }
    }

    func fetchRooms() {
        Firestore.firestore()
            .collection("rooms")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                rooms = documents.compactMap { doc in
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
            }
    }
}
