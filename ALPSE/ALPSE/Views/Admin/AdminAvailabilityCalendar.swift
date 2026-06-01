//
//  AdminAvailabilityCalendar.swift
//  ALPSE
//
//  SwiftUI wrapper around UICalendarView that color-codes each day based
//  on existing bookings: red dot for fully unavailable, orange dot for
//  the booking currently being edited.
//

import SwiftUI
import UIKit

struct AdminAvailabilityCalendar: UIViewRepresentable {

    /// Dates that already have at least one accepted/pending booking.
    var unavailableDates: Set<Date>

    /// The date of the booking currently being edited (highlighted in orange).
    var currentBookingDate: Date?

    /// Selected date binding.
    @Binding var selectedDate: Date

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = Calendar(identifier: .gregorian)
        view.delegate = context.coordinator

        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: selectedDate
        )
        view.selectionBehavior = selection

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parent = self

        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: selectedDate
            )
            if selection.selectedDate != comps {
                selection.setSelected(comps, animated: false)
            }
        }

        // Force redraw of decorations whenever availability data changes.
        let allComponents = (unavailableDates.union(currentBookingDate.map { [$0] } ?? []))
            .map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
        uiView.reloadDecorations(forDateComponents: allComponents, animated: false)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: AdminAvailabilityCalendar

        init(parent: AdminAvailabilityCalendar) {
            self.parent = parent
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            let stripped = Calendar.current.startOfDay(for: date)

            if let current = parent.currentBookingDate,
               Calendar.current.isDate(stripped, inSameDayAs: current) {
                return .default(color: .systemOrange, size: .large)
            }

            if parent.unavailableDates.contains(stripped) {
                return .default(color: .systemRed, size: .large)
            }

            return nil
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let comps = dateComponents,
                  let date = Calendar.current.date(from: comps) else { return }
            DispatchQueue.main.async {
                self.parent.selectedDate = date
            }
        }
    }
}
