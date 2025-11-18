// NotificationManager.swift
// DrNote2
//
// Centralized helper for local notifications (requesting permission,
// scheduling 1-day-before reminders for appointments, and canceling them).

import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private override init() { }

    // Keep a delegate instance alive to receive foreground notifications.
    private let center = UNUserNotificationCenter.current()

    func configureDelegate() {
        center.delegate = self
    }

    @MainActor
    func requestAuthorizationIfNeeded() async {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if !granted {
                    // You could log or present UI to guide the user to Settings.
                }
            } catch {
                // Handle errors if needed
                print("Notification authorization error: \(error)")
            }
        default:
            break
        }
    }

    func scheduleReminder(for appt: Appointment) {
        // Build the trigger time: 1 day before the appointment's date/time.
        let cal = Calendar.current
        let oneDayBefore = cal.date(byAdding: .day, value: -1, to: appt.date) ?? appt.date

        // If 1-day-before is already in the past, schedule soon (e.g., in 5 seconds)
        let fireDate = max(oneDayBefore, Date().addingTimeInterval(5))

        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Appointment Reminder"
        let name = appt.patient?.fullName ?? "Patient"
        let timeText = appt.date.formatted(date: .omitted, time: .shortened)
        content.body = "\(appt.reason) with \(name) at \(timeText) (tomorrow)."
        content.sound = .default

        let request = UNNotificationRequest(identifier: appt.notificationID, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }

    func cancelReminder(for appt: Appointment) {
        center.removePendingNotificationRequests(withIdentifiers: [appt.notificationID])
    }

    func rescheduleReminder(for appt: Appointment) {
        cancelReminder(for: appt)
        scheduleReminder(for: appt)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    // Show alert/sound when app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .list]
    }
}
