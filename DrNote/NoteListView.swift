import SwiftUI
import SwiftData

struct NoteListView: View {
    @Query(sort: [SortDescriptor<Note>(\.createdAt, order: .reverse)]) private var notes: [Note]

    var body: some View {
        List {
            ForEach(notes) { note in
                NavigationLink(value: note.id) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title).font(.headline)
                        HStack {
                            if let name = note.patient?.fullName { Text(name) }
                            Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Notes")
        .toolbar {
            NavigationLink(value: Route.addNote) { Image(systemName: "plus") }
        }
        .navigationDestination(for: Route.self) { route in
            if case .addNote = route {
                NoteFormView()
            }
        }
        .navigationDestination(for: PersistentIdentifier.self) { nid in
            if let n = notes.first(where: { $0.id == nid }) {
                NoteFormView(existing: n)
            } else {
                Text("Note not found")
            }
        }
    }
}

