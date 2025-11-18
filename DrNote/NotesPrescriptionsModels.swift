import Foundation
import SwiftData

@Model
final class Note {
    @Relationship var patient: Patient?
    var title: String
    var body: String?
    var createdAt: Date

    init(patient: Patient?, title: String, body: String? = nil, createdAt: Date = .now) {
        self.patient = patient
        self.title = title
        self.body = body
        self.createdAt = createdAt
    }
}

@Model
final class Prescription {
    @Relationship var patient: Patient?
    var medication: String
    var dosage: String?
    var instructions: String?
    var createdAt: Date

    init(patient: Patient?, medication: String, dosage: String? = nil, instructions: String? = nil, createdAt: Date = .now) {
        self.patient = patient
        self.medication = medication
        self.dosage = dosage
        self.instructions = instructions
        self.createdAt = createdAt
    }
}

