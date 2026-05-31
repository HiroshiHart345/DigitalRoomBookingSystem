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

        ZStack {

            Color.alpseOrange
                .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 15) {

                    ForEach(rooms) { room in

                        NavigationLink {

                            BookingFormView(
                                user: user,
                                room: room
                            )

                        } label: {

                            VStack(alignment: .leading) {

                                Text(room.name)
                                    .font(.headline)

                                Text("Capacity: \(room.capacity)")

                                if room.facultyRoom {

                                    Text(room.facultyName)
                                        .foregroundColor(.orange)

                                }

                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)

                        }

                    }

                }
                .padding()

            }

        }
        .navigationTitle("Rooms")
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

