//
//  Untitled.swift
//  DrNote2
//
//  Created by Fatemeh Pourebrahim on 12/11/25.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Create or edit a patient.
struct PatientFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    /// Existing patient to edit; if nil we create a new one.
    var existing: Patient?

    @State private var fullName = ""
    @State private var ageStr = ""
    @State private var gender: Gender = .undisclosed
    @State private var phone = ""
    @State private var tags = ""
    @State private var notes = ""

    // Avatar state
    @State private var avatarData: Data?
    @State private var pickerItem: PhotosPickerItem?

    private var avatarImage: Image? {
        guard let data = avatarData, let ui = UIImage(data: data) else { return nil }
        return Image(uiImage: ui)
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
            Form {
                Section("Identity") {
                    HStack(spacing: 16) {
                        ZStack {
                            if let img = avatarImage {
                                img
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.blue)
                                    .padding(6)
                            }
                        }
                        .frame(width: 64, height: 64)
                        .background(Color.white.opacity(0.6))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue.opacity(0.3), lineWidth: 1))

                        VStack(alignment: .leading) {
                            TextField("Full name *", text: $fullName)
                            TextField("Age", text: $ageStr)
                                .keyboardType(.numberPad)
                        }
                    }
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases) { g in
                            Text(g.label).tag(g)
                        }
                    }

                    HStack {
                        PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                            Label("Change Photo", systemImage: "photo.on.rectangle")
                        }
                        if avatarData != nil {
                            Spacer()
                            Button(role: .destructive) {
                                avatarData = nil
                            } label: {
                                Label("Remove Photo", systemImage: "trash")
                            }
                        }
                    }
                }
                Section("Contact") {
                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                Section("Clinical") {
                    TextField("Tags (comma separated)", text: $tags)
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(existing == nil ? "Add Patient" : "Edit Patient")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(fullName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear(perform: loadIfNeeded)
        .onChange(of: pickerItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    avatarData = downscaleImageDataIfNeeded(data, maxDimension: 512)
                }
            }
        }
    }

    /// Load existing values when editing.
    private func loadIfNeeded() {
        guard let p = existing else { return }
        fullName = p.fullName
        ageStr = p.age.map(String.init) ?? ""
        gender = p.gender
        phone = p.phone ?? ""
        tags = p.tags ?? ""
        notes = p.notes ?? ""
        avatarData = p.avatarData
    }

    /// Persist changes using SwiftData.
    private func save() {
        let age = Int(ageStr)
        if let p = existing {
            p.fullName = fullName
            p.age = age
            p.gender = gender
            p.phone = phone.isEmpty ? nil : phone
            p.tags = tags.isEmpty ? nil : tags
            p.notes = notes.isEmpty ? nil : notes
            p.avatarData = avatarData
        } else {
            let p = Patient(
                fullName: fullName,
                age: age,
                gender: gender,
                phone: phone.isEmpty ? nil : phone,
                notes: notes.isEmpty ? nil : notes,
                tags: tags.isEmpty ? nil : tags,
                avatarData: avatarData
            )
            context.insert(p)
        }
        try? context.save()
        dismiss()
    }

    private func downscaleImageDataIfNeeded(_ data: Data, maxDimension: CGFloat) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return data }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized?.jpegData(compressionQuality: 0.85) ?? data
    }
}
