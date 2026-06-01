//
//  AdminAvailabilityTimeSlots.swift
//  ALPSE
//
//  Hourly time-slot picker that color-codes each slot based on conflicts
//  with existing bookings on the selected date.
//

import SwiftUI

struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let startHour: Int
    let endHour: Int

    var label: String {
        String(format: "%02d:00 - %02d:00", startHour, endHour)
    }
}

/// Read-only reference view. Shows which hourly slots on `selectedDate`
/// are taken by other bookings (red), which one belongs to the booking
/// being edited (orange), and which are free. Does NOT drive selection —
/// admin still picks start/end via the standard DatePicker next to it.
struct AdminAvailabilityTimeSlots: View {

    var bookedRanges: [(start: Date, end: Date)]
    var currentRange: (start: Date, end: Date)?
    var selectedDate: Date

    private let slots: [TimeSlot] = (7..<17).map { hour in
        TimeSlot(startHour: hour, endHour: hour + 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Room Availability (reference)")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(slots, id: \.id) { slot in
                let slotStart = projectedDate(hour: slot.startHour)
                let slotEnd = projectedDate(hour: slot.endHour)
                let availability = classify(slotStart: slotStart, slotEnd: slotEnd)

                HStack {
                    Text(slot.label)
                        .foregroundColor(textColor(for: availability))
                    Spacer()
                    if availability == .unavailable {
                        Text("Not Available")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if availability == .current {
                        Text("Current Booking")
                            .font(.caption)
                            .foregroundColor(.alpseOrange)
                    }
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
    }

    private enum SlotAvailability {
        case available, current, unavailable
    }

    private func classify(slotStart: Date, slotEnd: Date) -> SlotAvailability {
        if let current = currentRange, overlaps(slotStart, slotEnd, current.start, current.end) {
            return .current
        }
        for range in bookedRanges {
            if overlaps(slotStart, slotEnd, range.start, range.end) {
                return .unavailable
            }
        }
        return .available
    }

    private func overlaps(_ aStart: Date, _ aEnd: Date, _ bStart: Date, _ bEnd: Date) -> Bool {
        aStart < bEnd && aEnd > bStart
    }

    private func textColor(for availability: SlotAvailability) -> Color {
        switch availability {
        case .available: return .black
        case .current: return .alpseOrange
        case .unavailable: return .red
        }
    }

    private func projectedDate(hour: Int) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: selectedDate)
        comps.hour = hour
        comps.minute = 0
        return cal.date(from: comps) ?? selectedDate
    }
}
