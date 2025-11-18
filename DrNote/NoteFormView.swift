import SwiftUI
import SwiftData

struct NoteFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Patient>(\.fullName)]) private var patients: [Patient]

    var existing: Note?

    @State private var selectedPatient: Patient?
    @State private var title = ""
    @State private var bodyText = ""

    var body: some View {
        Form {
            Section("Context") {
                Picker("Patient", selection: $selectedPatient) {
                    Text("None").tag(Optional<Patient>.none)
                    ForEach(patients) { p in
                        Text(p.fullName).tag(Optional(p))
                    }
                }
                TextField("Title *", text: $title)
            }
            Section("Body") {
                TextEditor(text: $bodyText).frame(minHeight: 160)
            }
        }
        .navigationTitle(existing == nil ? "Add Note" : "Edit Note")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear(perform: loadIfNeeded)
    }

    private func loadIfNeeded() {
        guard let n = existing else { return }
        selectedPatient = n.patient
        title = n.title
        bodyText = n.body ?? ""
    }

    private func save() {
        if let n = existing {
            n.patient = selectedPatient
            n.title = title
            n.body = bodyText.isEmpty ? nil : bodyText
        } else {
            let n = Note(patient: selectedPatient, title: title, body: bodyText.isEmpty ? nil : bodyText)
            context.insert(n)
        }
        try? context.save()
        dismiss()
    }
}

