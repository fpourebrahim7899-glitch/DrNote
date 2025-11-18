//
//  Models.swift
//  DrNote2
//
//  Created by Fatemeh Pourebrahim on 12/11/25.
//
import Foundation
import SwiftData

/// Gender options used by Patient.
enum Gender: String, Codable, CaseIterable, Identifiable {
    case female, male, other, undisclosed
    var id: String { rawValue }
    var label: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        case .undisclosed: return "Prefer not to say"
        }
    }
}

/// A person receiving care. Stored locally with SwiftData.
@Model
final class Patient {
    /// Human‑readable name. Required.
    var fullName: String
    /// Optional age (years). Keep it simple for MVP.
    var age: Int?
    /// Optional gender.
    var genderRaw: String
    /// Optional phone (string so we keep formatting as typed).
    var phone: String?
    /// Free‑text clinical notes.
    var notes: String?
    /// Comma‑separated tags (e.g., "diabetes, hypertension").
    var tags: String?
    /// Profile picture data (JPEG/PNG). Optional.
    var avatarData: Data?
    /// Creation timestamp.
    var createdAt: Date

    /// Back‑reference: a patient may have many appointments.
    @Relationship(deleteRule: .cascade, inverse: \Appointment.patient)
    var appointments: [Appointment] = []

    init(fullName: String,
         age: Int? = nil,
         gender: Gender = .undisclosed,
         phone: String? = nil,
         notes: String? = nil,
         tags: String? = nil,
         avatarData: Data? = nil,
         createdAt: Date = .now) {
        self.fullName = fullName
        self.age = age
        self.genderRaw = gender.rawValue
        self.phone = phone
        self.notes = notes
        self.tags = tags
        self.avatarData = avatarData
        self.createdAt = createdAt
    }

    /// Typed access to gender.
    var gender: Gender {
        get { Gender(rawValue: genderRaw) ?? .undisclosed }
        set { genderRaw = newValue.rawValue }
    }
}

/// An appointment for a specific patient on a given date/time.
@Model
final class Appointment {
    /// The patient this appointment belongs to.
    @Relationship var patient: Patient?
    /// Scheduled start time.
    var date: Date
    /// Short reason / title (e.g., "Follow‑up: BP check").
    var reason: String
    /// Free‑text notes.
    var notes: String?
    /// Status: scheduled, completed, canceled (string for MVP).
    var status: String
    /// Creation timestamp.
    var createdAt: Date
    /// Stable identifier used for scheduling/canceling notifications.
    var notificationID: String = UUID().uuidString

    init(patient: Patient?, date: Date, reason: String, notes: String? = nil, status: String = "scheduled", createdAt: Date = .now) {
        self.patient = patient
        self.date = date
        self.reason = reason
        self.notes = notes
        self.status = status
        self.createdAt = createdAt
    }
}
