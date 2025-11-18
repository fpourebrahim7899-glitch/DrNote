//
//  PatientListView.swift
//  DrNote2
//
//  Created by Fatemeh Pourebrahim on 12/11/25.
//

import SwiftUI
import SwiftData

/// Shows all patients with search and basic sorting.
struct PatientListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<Patient>(\.createdAt, order: .reverse)])
    private var patients: [Patient]

    @State private var search = ""

    /// Returns patients filtered by the current search query.
    private var filteredPatients: [Patient] {
        guard !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return patients
        }
        let q = search.lowercased()
        return patients.filter { p in
            let name = p.fullName.lowercased()
            let phone = p.phone?.lowercased() ?? ""
            let tags = p.tags?.lowercased() ?? ""
            return name.contains(q) || phone.contains(q) || tags.contains(q)
        }
    }

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
                if filteredPatients.isEmpty {
                    ContentUnavailableView.search(text: search)
                } else {
                    ForEach(filteredPatients) { patient in
                        NavigationLink {
                            // Edit in form
                            PatientFormView(existing: patient)
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(data: patient.avatarData)
                                VStack(alignment: .leading) {
                                    Text(patient.fullName)
                                        .font(.headline)
                                    HStack(spacing: 8) {
                                        if let age = patient.age {
                                            Text("Age: \(age)")
                                        }
                                        Text(patient.gender.label)
                                        if let phone = patient.phone, !phone.isEmpty {
                                            Text("• \(phone)")
                                        }
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                context.delete(patient)
                                try? context.save()
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Patients")
        // Make the search bar prominent in the navigation bar
        .searchable(
            text: $search,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search by name, phone, or tags"
        )
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
    }
}

private struct AvatarView: View {
    let data: Data?

    var body: some View {
        ZStack {
            if let data, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                    .padding(4)
            }
        }
        .frame(width: 44, height: 44)
        .background(Color.white.opacity(0.6))
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.blue.opacity(0.25), lineWidth: 1))
    }
}

#Preview {
    NavigationStack {
        PatientListView()
    }
    .modelContainer(for: [Patient.self, Appointment.self], inMemory: true)
}
