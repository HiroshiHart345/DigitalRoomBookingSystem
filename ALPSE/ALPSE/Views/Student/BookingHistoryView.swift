//
//  BookingHistoryView.swift
//  ALPSE
//
//  Created by ~ Natalie ~ on 28/05/26.
//


import SwiftUI
import FirebaseFirestore

struct BookingHistoryView: View {

    let user: UserModel

    @State private var bookings: [Booking] = []

    var body: some View {

        ZStack {

            Color.alpseOrange
                .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 15) {

                    Text("HISTORY BOOKING")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    if bookings.isEmpty {

                        VStack {

                            Spacer()

                            Text("No Booking Made Yet")
                                .foregroundColor(.white)
                                .font(.headline)

                            Spacer()

                        }
                        .frame(maxWidth: .infinity, minHeight: 500)

                    } else {

                        ForEach(bookings) { booking in

                            NavigationLink {

                                BookingDetailView(
                                    booking: booking
                                )

                            } label: {

                                VStack(alignment: .leading, spacing: 8) {

                                    Text(booking.roomName)
                                        .font(.headline)

                                    Text(booking.activityName)

                                    Text(booking.status)
                                        .foregroundColor(
                                            booking.status.contains("Rejected")
                                            ? .red
                                            : .orange
                                        )

                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)

                            }

                        }

                    }

                }
                .padding()

            }

        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {

            fetchBookings()

        }

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
