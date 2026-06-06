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
    @StateObject private var viewModel = RoomViewModel()

    var body: some View {
        List {
            ForEach(viewModel.rooms) { room in
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
            viewModel.fetchRooms()
        }
    }

}
