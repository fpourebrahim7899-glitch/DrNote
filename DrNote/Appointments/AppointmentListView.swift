//
//  AppointmentListView.swift
//  DrNote2
//
//  Created by Fatemeh Pourebrahim on 12/11/25.
//

import SwiftUI
import SwiftData

/// Shows all appointments with basic grouping by day.
struct AppointmentListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Appointment>(\.date, order: .forward)]) private var appointments: [Appointment]

    private var softPurpleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: 0.58, saturation: 0.35, brightness: 0.98).opacity(0.22),
                Color(hue: 0.58, saturation: 0.22, brightness: 1.00).opacity(0.12),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            softPurpleGradient.ignoresSafeArea()
            List {
                ForEach(appointments) { appt in
                    NavigationLink(value: appt.id) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appt.reason).font(.headline)
                            HStack {
                                Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                                if let name = appt.patient?.fullName {
                                    Text("• \(name)")
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            context.delete(appt)
                            try? context.save()
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Appointments")
        .toolbar { NavigationLink("Add", value: Route.addAppointment) }
        .navigationDestination(for: PersistentIdentifier.self) { aid in
            if let appt = appointments.first(where: { $0.id == aid }) {
                AppointmentFormView(existing: appt)
            } else { Text("Appointment not found") }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let appt = appointments[index]
            NotificationManager.shared.cancelReminder(for: appt)
            context.delete(appt)
        }
        try? context.save()
    }
}

