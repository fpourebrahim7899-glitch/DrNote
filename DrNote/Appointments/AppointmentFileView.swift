//
//  AppointmentFileView.swift
//  DrNote2
//
//  Created by Fatemeh Pourebrahim on 12/11/25.
//

import SwiftUI
import SwiftData

/// Create or edit an appointment.
struct AppointmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Patient>(\.fullName)]) private var patients: [Patient]

    var existing: Appointment?

    @State private var selectedPatient: Patient?
    @State private var date = Date()
    @State private var reason = ""
    @State private var notes = ""
    @State private var status = "scheduled"

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
            Form {
                Section("Who & When") {
                    Picker("Patient *", selection: $selectedPatient) {
                        Text("Select patient").tag(Optional<Patient>.none)
                        ForEach(patients) { p in
                            Text(p.fullName).tag(Optional(p))
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                Section("Details") {
                    TextField("Reason *", text: $reason)
                    TextField("Status", text: $status)
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(existing == nil ? "Add Appointment" : "Edit Appointment")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(selectedPatient == nil || reason.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear(perform: loadIfNeeded)
    }

    private func loadIfNeeded() {
        if let a = existing {
            selectedPatient = a.patient
            date = a.date
            reason = a.reason
            notes = a.notes ?? ""
            status = a.status
        }
    }

    private func save() {
        if let a = existing {
            a.patient = selectedPatient
            a.date = date
            a.reason = reason
            a.notes = notes.isEmpty ? nil : notes
            a.status = status
            try? context.save()
            // Reschedule reminder after edits
            NotificationManager.shared.rescheduleReminder(for: a)
        } else {
            let a = Appointment(patient: selectedPatient, date: date, reason: reason, notes: notes.isEmpty ? nil : notes, status: status)
            context.insert(a)
            try? context.save()
            // Schedule reminder for new appointment
            NotificationManager.shared.scheduleReminder(for: a)
        }
        dismiss()
    }
}

