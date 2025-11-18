import SwiftUI
import SwiftData

struct PrescriptionListView: View {
    @Query(sort: [SortDescriptor<Prescription>(\.createdAt, order: .reverse)]) private var prescriptions: [Prescription]

    var body: some View {
        List {
            ForEach(prescriptions) { rx in
                NavigationLink(value: rx.id) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rx.medication).font(.headline)
                        HStack {
                            if let name = rx.patient?.fullName { Text(name) }
                            Text(rx.createdAt.formatted(date: .abbreviated, time: .shortened))
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Prescriptions")
        .toolbar {
            NavigationLink(value: Route.addPrescription) { Image(systemName: "plus") }
        }
        .navigationDestination(for: Route.self) { route in
            if case .addPrescription = route {
                PrescriptionFormView()
            }
        }
        .navigationDestination(for: PersistentIdentifier.self) { rid in
            if let r = prescriptions.first(where: { $0.id == rid }) {
                PrescriptionFormView(existing: r)
            } else {
                Text("Prescription not found")
            }
        }
    }
}

