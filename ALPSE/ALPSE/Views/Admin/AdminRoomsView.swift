//
//  AdminRoomsView.swift
//  ALPSE
//

import SwiftUI

struct AdminRoomsView: View {

    @StateObject private var viewModel = AdminRoomsViewModel()

    @State private var showFormSheet = false
    @State private var editingRoom: Room? = nil
    @State private var roomPendingDeletion: Room? = nil

    var body: some View {
        ZStack {
            Color.alpseOrange.ignoresSafeArea()

            VStack(spacing: 0) {

                Text("ROOMS")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)

                ZStack(alignment: .top) {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text("MASTER DATA ROOMS")
                                .font(.subheadline)
                                .foregroundColor(.alpseOrange)
                            Spacer()
                            Button {
                                editingRoom = nil
                                showFormSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                        Divider()

                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.rooms) { room in
                                    AdminRoomRow(
                                        room: room,
                                        onTap: {
                                            editingRoom = room
                                            showFormSheet = true
                                        },
                                        onDelete: {
                                            roomPendingDeletion = room
                                        }
                                    )
                                    Divider()
                                }

                                if viewModel.rooms.isEmpty && !viewModel.isLoading {
                                    Text("No rooms yet. Tap + to add.")
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
        .onAppear {
            viewModel.fetchRooms()
        }
        .sheet(isPresented: $showFormSheet) {
            AdminRoomFormView(
                viewModel: viewModel,
                existingRoom: editingRoom
            )
        }
        .alert(
            "Delete \(roomPendingDeletion?.name ?? "Room")?",
            isPresented: Binding(
                get: { roomPendingDeletion != nil },
                set: { if !$0 { roomPendingDeletion = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { roomPendingDeletion = nil }
            Button("Confirm", role: .destructive) {
                if let room = roomPendingDeletion {
                    viewModel.deleteRoom(id: room.id)
                }
                roomPendingDeletion = nil
            }
        }
    }
}

private struct AdminRoomRow: View {
    let room: Room
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.name)
                        .font(.headline)
                        .foregroundColor(.black)
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(room.capacity)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        if room.facultyRoom {
                            Text("Faculty Room")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Not Faculty Room")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct AdminRoomFormView: View {

    @ObservedObject var viewModel: AdminRoomsViewModel
    let existingRoom: Room?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var capacityText: String = ""
    @State private var isFaculty: Bool = false
    @State private var facultyName: String = ""
    @State private var showDuplicateAlert: Bool = false

    private var isEditing: Bool { existingRoom != nil }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var capacityValue: Int {
        Int(capacityText) ?? 0
    }

    private var isFormValid: Bool {
        guard !trimmedName.isEmpty else { return false }
        guard capacityValue > 0 else { return false }
        if isFaculty && facultyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Room Name") {
                    TextField("Write New Room Name", text: $name)
                }
                Section("Room Capacity") {
                    TextField("Input New Room Capacity", text: $capacityText)
                        .keyboardType(.numberPad)
                }
                Section("Is The Room Faculty Room?") {
                    Toggle("Faculty Room", isOn: $isFaculty)
                    if isFaculty {
                        TextField("Faculty Name", text: $facultyName)
                    }
                }

                Section {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .background(isFormValid ? Color.alpseOrange : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(isEditing ? "Update \(existingRoom?.name ?? "Room")" : "Add New Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Duplicate Room Name",
                   isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A room with the name \"\(trimmedName)\" already exists. Please choose a different name.")
            }
            .onAppear(perform: prefill)
        }
    }

    private func prefill() {
        if let room = existingRoom {
            name = room.name
            capacityText = "\(room.capacity)"
            isFaculty = room.facultyRoom
            facultyName = room.facultyName
        }
    }

    private func save() {
        let excludeId = existingRoom?.id
        if viewModel.isDuplicateName(trimmedName, excludingId: excludeId) {
            showDuplicateAlert = true
            return
        }

        let capacity = capacityValue
        if let room = existingRoom {
            viewModel.updateRoom(
                id: room.id,
                name: trimmedName,
                capacity: capacity,
                isFaculty: isFaculty,
                facultyName: facultyName
            )
        } else {
            viewModel.createRoom(
                name: trimmedName,
                capacity: capacity,
                isFaculty: isFaculty,
                facultyName: facultyName
            )
        }
        dismiss()
    }
}
