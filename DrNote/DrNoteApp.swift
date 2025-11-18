import SwiftUI
import SwiftData

/// DoctorPad – Electronic Medical Records starter using SwiftUI + SwiftData.
@main
struct DoctorPadApp: App {
    /// The model container holds our local database for `Patient` and `Appointment`.
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Light purple background
                Color.purple.opacity(0.08)
                    .ignoresSafeArea()
                DashboardView()
                    .task {
                        // Ask once at launch; user can allow/deny.
                        await NotificationManager.shared.requestAuthorizationIfNeeded()
                        // Make sure foreground notifications show alerts/sounds.
                        NotificationManager.shared.configureDelegate()
                    }
            }
        }
        .modelContainer(for: [Patient.self, Appointment.self, Note.self, Prescription.self])
    }
}

