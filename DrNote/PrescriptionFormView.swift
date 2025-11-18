import SwiftUI
import SwiftData

struct PrescriptionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Patient>(\.fullName)]) private var patients: [Patient]

    var existing: Prescription?

    @State private var selectedPatient: Patient?
    @State private var medication = ""
    @State private var dosage = ""
    @State private var instructions = ""

    var body: some View {
        Form {
            Section("Patient") {
                Picker("Patient", selection: $selectedPatient) {
                    Text("Select patient").tag(Optional<Patient>.none)
                    ForEach(patients) { p in
                        Text(p.fullName).tag(Optional(p))
                    }
                }
            }
            Section("Medication") {
                TextField("Medication *", text: $medication)
                TextField("Dosage", text: $dosage)
                TextEditor(text: $instructions)
                    .frame(minHeight: 120)
                    .overlay(alignment: .topLeading) {
                        if instructions.isEmpty {
                            Text("Instructions")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
        .navigationTitle(existing == nil ? "Add Prescription" : "Edit Prescription")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(medication.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear(perform: loadIfNeeded)
    }

    private func loadIfNeeded() {
        guard let r = existing else { return }
        selectedPatient = r.patient
        medication = r.medication
        dosage = r.dosage ?? ""
        instructions = r.instructions ?? ""
    }

    private func save() {
        if let r = existing {
            r.patient = selectedPatient
            r.medication = medication
            r.dosage = dosage.isEmpty ? nil : dosage
            r.instructions = instructions.isEmpty ? nil : instructions
        } else {
            let r = Prescription(patient: selectedPatient,
                                 medication: medication,
                                 dosage: dosage.isEmpty ? nil : dosage,
                                 instructions: instructions.isEmpty ? nil : instructions)
            context.insert(r)
        }
        try? context.save()
        dismiss()
    }
}

