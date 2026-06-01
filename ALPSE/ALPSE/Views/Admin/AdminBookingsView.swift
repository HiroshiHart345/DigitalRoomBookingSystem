//
//  AdminBookingsView.swift
//  ALPSE
//

import SwiftUI
import FirebaseFirestore

struct AdminBookingsView: View {

    @StateObject private var viewModel = AdminBookingsViewModel()

    @State private var bookingPendingDeletion: Booking? = nil
    @State private var editingBooking: Booking? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.alpseOrange.ignoresSafeArea()

                VStack(spacing: 0) {

                    Text("BOOKING")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)

                    ZStack(alignment: .top) {
                        Color.white
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Text("MASTER DATA BOOKINGS")
                                    .font(.subheadline)
                                    .foregroundColor(.alpseOrange)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 8)

                            Divider()

                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.bookings) { booking in
                                        AdminBookingRow(
                                            booking: booking,
                                            onEdit: { editingBooking = booking },
                                            onDelete: { bookingPendingDeletion = booking }
                                        )
                                        Divider()
                                    }

                                    if viewModel.bookings.isEmpty && !viewModel.isLoading {
                                        Text("No bookings yet.")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 40)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .onAppear {
            viewModel.fetchBookings()
        }
        .sheet(item: $editingBooking) { booking in
            AdminBookingUpdateView(viewModel: viewModel, booking: booking)
        }
        .alert(
            "Delete \(bookingPendingDeletion?.activityName ?? "Booking")?",
            isPresented: Binding(
                get: { bookingPendingDeletion != nil },
                set: { if !$0 { bookingPendingDeletion = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { bookingPendingDeletion = nil }
            Button("Confirm", role: .destructive) {
                if let booking = bookingPendingDeletion {
                    viewModel.deleteBooking(id: booking.id)
                }
                bookingPendingDeletion = nil
            }
        }
    }
}

private struct AdminBookingRow: View {
    let booking: Booking
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            NavigationLink {
                AdminBookingDetailView(booking: booking)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.activityName.isEmpty ? "Booking \(booking.id.prefix(6))" : booking.activityName)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("\(booking.roomName) · \(booking.organization)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(booking.status)
                        .font(.caption)
                        .foregroundColor(statusColor(booking.status))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.alpseOrange)
                    .font(.title3)
            }

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private func statusColor(_ status: String) -> Color {
        let lower = status.lowercased()
        if lower.contains("approved") { return .green }
        if lower.contains("reject") { return .red }
        return .orange
    }
}

struct AdminBookingDetailView: View {
    let booking: Booking

    var body: some View {
        ZStack {
            Color.alpseOrange.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("HISTORY")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)

                ZStack(alignment: .top) {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detail Booking")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)

                        Divider()

                        Group {
                            Text(booking.roomName)
                                .font(.title3).bold()
                            Text(formattedDate(booking.date.dateValue()))
                            Text("\(formattedTime(booking.startTime.dateValue())) - \(formattedTime(booking.endTime.dateValue()))")
                        }

                        Divider()

                        infoRow(label: "Organizer", value: booking.organization)
                        infoRow(label: "Person In Charge", value: booking.userName)
                        infoRow(label: "Program's Name", value: booking.activityName)
                        infoRow(label: "Description", value: booking.description)
                        infoRow(label: "Status", value: booking.status)
                        if !booking.rejectionReason.isEmpty {
                            infoRow(label: "Rejection Reason", value: booking.rejectionReason)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .frame(width: 130, alignment: .leading)
                .foregroundColor(.gray)
            Text(":")
            Text(value)
                .foregroundColor(.black)
        }
        .font(.subheadline)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}

struct AdminBookingUpdateView: View {

    @ObservedObject var viewModel: AdminBookingsViewModel
    let booking: Booking

    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var status: String = "Pending SA Approval"
    @State private var reason: String = ""

    private let statusOptions: [String] = [
        "Pending SA Approval",
        "Pending AS Approval",
        "Pending PM Approval",
        "Approved",
        "Rejected"
    ]

    private var currentBookingDate: Date {
        Calendar.current.startOfDay(for: booking.date.dateValue())
    }

    private var unavailableDates: Set<Date> {
        Set(viewModel.roomBookings.map {
            Calendar.current.startOfDay(for: $0.date.dateValue())
        })
    }

    private var bookedRangesOnSelectedDate: [(start: Date, end: Date)] {
        viewModel.roomBookings
            .filter { Calendar.current.isDate($0.date.dateValue(), inSameDayAs: date) }
            .map { ($0.startTime.dateValue(), $0.endTime.dateValue()) }
    }

    private var currentRange: (start: Date, end: Date)? {
        guard Calendar.current.isDate(currentBookingDate, inSameDayAs: date) else {
            return nil
        }
        return (booking.startTime.dateValue(), booking.endTime.dateValue())
    }

    var body: some View {
        NavigationStack {
            Form {

                Section("Date") {
                    AdminAvailabilityCalendar(
                        unavailableDates: unavailableDates,
                        currentBookingDate: currentBookingDate,
                        selectedDate: $date
                    )
                    .frame(minHeight: 320)
                    HStack(spacing: 16) {
                        legendDot(color: .red, label: "Unavailable")
                        legendDot(color: .orange, label: "Current")
                    }
                    .font(.caption)
                }

                Section("Start Time") {
                    DatePicker(
                        "Start",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("End Time") {
                    DatePicker(
                        "End",
                        selection: $endTime,
                        displayedComponents: .hourAndMinute
                    )
                }

                Section("Room Availability") {
                    AdminAvailabilityTimeSlots(
                        bookedRanges: bookedRangesOnSelectedDate,
                        currentRange: currentRange,
                        selectedDate: date
                    )
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(statusOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    if status == "Rejected" {
                        TextField("Rejection Reason", text: $reason)
                    }
                }

                Section {
                    Button {
                        viewModel.updateBooking(
                            id: booking.id,
                            date: date,
                            startTime: startTime,
                            endTime: endTime,
                            status: status,
                            reason: reason
                        )
                        dismiss()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .background(Color.alpseOrange)
                            .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Update Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                prefill()
                viewModel.fetchRoomBookings(roomId: booking.roomId, excluding: booking.id)
            }
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundColor(.gray)
        }
    }

    private func prefill() {
        date = booking.date.dateValue()
        startTime = booking.startTime.dateValue()
        endTime = booking.endTime.dateValue()
        status = statusOptions.contains(booking.status) ? booking.status : "Pending SA Approval"
        reason = booking.rejectionReason
    }
}
