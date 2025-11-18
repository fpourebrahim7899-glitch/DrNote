//
//  DashboardView.swift
//  DrNote2
//
//  Created by Fatemeh Pourebrahim on 12/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData
import UIKit

/// The main container now presents Home and a Calendar tab.
struct DashboardView: View {
    @State private var homePath = NavigationPath()
    @State private var calendarPath = NavigationPath()

    @State private var showProfile = false
    @State private var confirmSignOut = false

    // Pull the doctor name and avatar image stored by DoctorProfileSheet
    @AppStorage("doctor_name") private var storedDoctorName: String = "Dr. Jane Doe"
    @AppStorage("doctor_avatar") private var avatarData: Data?

    private var doctorName: String { storedDoctorName }
    private var avatarImage: Image? {
        guard let data = avatarData, let ui = UIImage(data: data) else { return nil }
        return Image(uiImage: ui)
    }

    var body: some View {
        TabView {
            // MARK: - Home Tab
            NavigationStack(path: $homePath) {
                ZStack {
                    BackgroundCanvas().ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {

                            // Header card with avatar and greeting
                            HeaderCard(avatarImage: avatarImage, name: doctorName)

                            // Five primary buttons for Patients, Appointments, Notes, Prescriptions, Patient History
                            HomeButtons(
                                openPatients: { homePath.append(Route.patientList) },
                                openAppointments: { homePath.append(Route.appointmentList) },
                                openNotes: { homePath.append(Route.noteList) },
                                openPrescriptions: { homePath.append(Route.prescriptionList) },
                                openHistory: { homePath.append(Route.historyList) }
                            )
                            .padding(.horizontal)

                            Spacer(minLength: 16)
                        }
                        .padding(.top)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Settings button on the top-left (replaces profile menu)
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showProfile = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.primary)
                                .accessibilityLabel("Settings")
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 8) {
                            Image(systemName: "stethoscope")
                                .foregroundStyle(.blue)
                            Text("DrNote")
                                .font(.headline)
                        }
                    }

                    // Sandwich (hamburger) menu on the top-right with actions
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                homePath.append(Route.addPatient)
                            } label: {
                                Label("Add Patient", systemImage: "person.badge.plus")
                            }
                            Button {
                                homePath.append(Route.addAppointment)
                            } label: {
                                Label("Add Appointment", systemImage: "calendar.badge.plus")
                            }
                            Button {
                                homePath.append(Route.addNote)
                            } label: {
                                Label("Add Note", systemImage: "note.text.badge.plus")
                            }
                            Button {
                                homePath.append(Route.addPrescription)
                            } label: {
                                Label("Add Prescription", systemImage: "pills.circle")
                            }
                            Button {
                                homePath.append(Route.historyList)
                            } label: {
                                Label("Patient History", systemImage: "clock.arrow.circlepath")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.circle")
                                .font(.title3)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.primary)
                                .accessibilityLabel("More Actions")
                        }
                    }
                }
                .toolbarBackground(.thinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .sheet(isPresented: $showProfile) {
                    DoctorProfileSheet()
                        .presentationDetents([.medium, .large])
                }
                .alert("Sign Out?", isPresented: $confirmSignOut) {
                    Button("Cancel", role: .cancel) { }
                    Button("Sign Out", role: .destructive) {
                        // TODO: handle sign out logic
                    }
                } message: {
                    Text("You will need to sign in again to continue.")
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .patientList:
                        PatientListView()
                    case .addPatient:
                        PatientFormView()
                    case .appointmentList:
                        AppointmentListView()
                    case .addAppointment:
                        AppointmentFormView()
                    case .noteList:
                        NoteListView()
                    case .addNote:
                        NoteFormView()
                    case .prescriptionList:
                        PrescriptionListView()
                    case .addPrescription:
                        PrescriptionFormView()
                    case .historyList:
                        PatientHistoryListView()
                    }
                }
                // Navigate from history list to a specific patient's history detail
                .navigationDestination(for: PersistentIdentifier.self) { pid in
                    PatientHistoryDetailDestination(patientID: pid)
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            // MARK: - Calendar Tab
            NavigationStack(path: $calendarPath) {
                YearCalendarView()
                    .navigationTitle("Calendar")
                    .toolbar {
                        // Sandwich menu on the right for calendar actions
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button {
                                    calendarPath.append(Route.addAppointment)
                                } label: {
                                    Label("Add Appointment", systemImage: "calendar.badge.plus")
                                }
                                Button {
                                    calendarPath.append(Route.addNote)
                                } label: {
                                    Label("Add Note", systemImage: "note.text.badge.plus")
                                }
                                Button {
                                    calendarPath.append(Route.addPrescription)
                                } label: {
                                    Label("Add Prescription", systemImage: "pills.circle")
                                }
                                Button {
                                    calendarPath.append(Route.historyList)
                                } label: {
                                    Label("Patient History", systemImage: "clock.arrow.circlepath")
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.circle")
                                    .font(.title3)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.primary)
                                    .accessibilityLabel("Calendar Actions")
                            }
                        }
                    }
                    // Tap a day pushes to its appointments
                    .navigationDestination(for: Date.self) { date in
                        DayAppointmentsView(date: date)
                    }
                    // Keep existing Route for adding appointment if needed
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .addAppointment:
                            AppointmentFormView()
                        case .appointmentList:
                            AppointmentListView()
                        case .patientList:
                            PatientListView()
                        case .addPatient:
                            PatientFormView()
                        case .noteList:
                            NoteListView()
                        case .addNote:
                            NoteFormView()
                        case .prescriptionList:
                            PrescriptionListView()
                        case .addPrescription:
                            PrescriptionFormView()
                        case .historyList:
                            PatientHistoryListView()
                        }
                    }
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
        }
        // Make tab bar selected item (e.g., Home) blue instead of default
        .tint(.blue)
    }
}

// MARK: - Background

private struct BackgroundCanvas: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Soft blue gradient background
            LinearGradient(
                colors: [
                    Color(hue: 0.58, saturation: 0.35, brightness: 0.98).opacity(0.22),
                    Color(hue: 0.58, saturation: 0.22, brightness: 1.00).opacity(0.12),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft moving blobs
            Circle()
                .fill(Color.blue.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: animate ? -160 : -120, y: animate ? -140 : -100)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)

            Circle()
                .fill(Color.cyan.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: animate ? 160 : 120, y: animate ? 140 : 100)
                .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: animate)

            // Vignette
            LinearGradient(
                colors: [Color.black.opacity(0.04), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
        }
        .onAppear { animate = true }
    }
}

// MARK: - Header

private struct HeaderCard: View {
    let avatarImage: Image?
    let name: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.25), lineWidth: 1)
                    )

                if let img = avatarImage {
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .frame(width: 40, height: 40)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(name)
                    .font(.title3.weight(.semibold))
            }

            Spacer()

            Image(systemName: "cross.case.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.blue, Color.blue.opacity(0.4))
                .font(.system(size: 28, weight: .semibold))
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Upcoming Appointment Card

private struct UpcomingAppointmentCard: View {
    // Query the next upcoming appointment
    @Query private var upcoming: [Appointment]

    init() {
        let now = Date()
        _upcoming = Query(
            filter: #Predicate<Appointment> { appt in
                appt.date >= now
            },
            sort: [SortDescriptor(\Appointment.date, order: .forward)],
            animation: .easeInOut
        )
    }

    var body: some View {
        if let appt = upcoming.first {
            GlassCard {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.blue)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Next Appointment")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(appt.reason)
                            .font(.headline)
                        HStack(spacing: 6) {
                            Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                            if let name = appt.patient?.fullName {
                                Text("• \(name)")
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Home Buttons (Patients + Appointments + Notes + Prescriptions + Patient History)

private struct HomeButtons: View {
    let openPatients: () -> Void
    let openAppointments: () -> Void
    let openNotes: () -> Void
    let openPrescriptions: () -> Void
    let openHistory: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: openPatients) {
                GlassCard {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.cyan.opacity(0.16))
                                .frame(width: 44, height: 44)
                            Image(systemName: "person.circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.cyan)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Patients")
                                .font(.headline)
                            Text("Browse and manage")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button(action: openAppointments) {
                GlassCard {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.16))
                                .frame(width: 44, height: 44)
                            Image(systemName: "checklist")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.blue)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Appointments")
                                .font(.headline)
                            Text("View upcoming")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button(action: openNotes) {
                GlassCard {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.green.opacity(0.16))
                                .frame(width: 44, height: 44)
                            Image(systemName: "note.text")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.green)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.headline)
                            Text("Clinical notes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button(action: openPrescriptions) {
                GlassCard {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.purple.opacity(0.16))
                                .frame(width: 44, height: 44)
                            Image(systemName: "pills.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.purple)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prescriptions")
                                .font(.headline)
                            Text("Medications & doses")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button(action: openHistory) {
                GlassCard {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.orange.opacity(0.16))
                                .frame(width: 44, height: 44)
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.orange)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Patient History")
                                .font(.headline)
                            Text("Timeline & summaries")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

// MARK: - Glass Card

private struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

/// Editable profile sheet with persistent fields and avatar photo.
private struct DoctorProfileSheet: View {
    // Persisted doctor profile fields
    @AppStorage("doctor_name") private var name: String = "Dr. Jane Doe"
    @AppStorage("doctor_specialty") private var specialty: String = "General Practitioner"
    @AppStorage("doctor_email") private var email: String = "jane.doe@example.com"
    @AppStorage("doctor_phone") private var phone: String = "+1 (555) 123-4567"
    @AppStorage("doctor_location") private var location: String = "Downtown Medical Center"
    @AppStorage("doctor_hours") private var hours: String = "Mon–Fri, 9am–5pm"
    // Persist avatar image as Data
    @AppStorage("doctor_avatar") private var avatarData: Data?

    @State private var pickerItem: PhotosPickerItem?

    @Environment(\.dismiss) private var dismiss

    private var softBlueGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: 0.58, saturation: 0.35, brightness: 0.98, opacity: 1).opacity(0.22),
                Color(hue: 0.58, saturation: 0.22, brightness: 1.00, opacity: 1).opacity(0.12),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var avatarImage: Image? {
        guard let data = avatarData, let ui = UIImage(data: data) else { return nil }
        return Image(uiImage: ui)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                softBlueGradient.ignoresSafeArea()
                Form {
                    Section {
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
                                TextField("Full name", text: $name)
                                    .textContentType(.name)
                                    .font(.headline)
                                TextField("Specialty", text: $specialty)
                                    .textContentType(.jobTitle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)

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
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                        TextField("Phone", text: $phone)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    }

                    Section("Clinic") {
                        TextField("Location", text: $location)
                        TextField("Hours", text: $hours)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    avatarData = downscaleImageDataIfNeeded(data, maxDimension: 512)
                }
            }
        }
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

// MARK: - Yearly Calendar

private struct YearCalendarView: View {
    @Environment(\.calendar) private var calendar
    @Query(sort: [SortDescriptor<Appointment>(\.date, order: .forward)])
    private var allAppointments: [Appointment]

    @State private var year: Int = Calendar.current.component(.year, from: Date())

    private var months: [Int] { Array(1...12) }

    // Map yyyy-mm-dd -> appointments on that day
    private var apptsByDay: [DateComponents: [Appointment]] {
        let cal = calendar
        let filtered = allAppointments.filter { appt in
            cal.component(.year, from: appt.date) == year
        }
        return Dictionary(grouping: filtered) { appt in
            cal.dateComponents([.year, .month, .day], from: appt.date)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Year selector
                HStack {
                    Button {
                        year -= 1
                    } label: {
                        Image(systemName: "chevron.left.circle.fill").font(.title3)
                    }
                    Text("\(year)").font(.title2.weight(.semibold))
                    Button {
                        year += 1
                    } label: {
                        Image(systemName: "chevron.right.circle.fill").font(.title3)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // 12 months grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(months, id: \.self) { month in
                        MonthView(year: year, month: month, apptsByDay: apptsByDay)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.top, 8)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(hue: 0.58, saturation: 0.35, brightness: 0.98, opacity: 1).opacity(0.22),
                    Color(hue: 0.58, saturation: 0.22, brightness: 1.00, opacity: 1).opacity(0.12),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

private struct MonthView: View {
    @Environment(\.calendar) private var calendar

    let year: Int
    let month: Int
    let apptsByDay: [DateComponents: [Appointment]]

    private var monthName: String {
        let comps = DateComponents(year: year, month: month)
        let date = calendar.date(from: comps) ?? .now
        let fmt = DateFormatter()
        fmt.dateFormat = "LLLL"
        return fmt.string(from: date)
    }

    private var daysGrid: [Date?] {
        let comps = DateComponents(year: year, month: month)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) // 1=Sun ... 7=Sat (default)
        let leadingBlanks = (firstWeekday + 6) % 7 // Sunday-first grid

        var grid: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in range {
            var c = DateComponents(year: year, month: month, day: day)
            c.hour = 12 // avoid DST issues
            grid.append(calendar.date(from: c))
        }
        while grid.count % 7 != 0 { grid.append(nil) }
        return grid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthName)
                .font(.headline)
                .padding(.horizontal, 8)
                .padding(.top, 8)

            // Weekday headers
            let symbols = calendar.shortWeekdaySymbols
            HStack {
                ForEach(symbols, id: \.self) { s in
                    Text(s.prefix(3))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)

            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(Array(daysGrid.enumerated()), id: \.offset) { _, date in
                    if let d = date {
                        let comps = calendar.dateComponents([.year, .month, .day], from: d)
                        let key = DateComponents(year: comps.year, month: comps.month, day: comps.day)
                        let hasAppt = apptsByDay[key] != nil

                        if hasAppt {
                            NavigationLink(value: d) {
                                DayCell(date: d, hasAppt: true)
                            }
                            .buttonStyle(.plain)
                        } else {
                            DayCell(date: d, hasAppt: false)
                        }
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 28)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }
}

private struct DayCell: View {
    @Environment(\.calendar) private var calendar
    let date: Date
    let hasAppt: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .background(
                    (calendar.isDateInToday(date) ? Color.blue.opacity(0.12) : Color.clear)
                        .clipShape(Capsule())
                )
            Circle()
                .fill(hasAppt ? Color.blue : Color.clear)
                .frame(width: 4, height: 4)
                .opacity(hasAppt ? 0.9 : 0.0)
        }
        .frame(height: 28)
    }
}

// MARK: - Day Appointments

private struct DayAppointmentsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var appointments: [Appointment]

    private let date: Date
    private let startOfDay: Date
    private let endOfDay: Date

    init(date: Date) {
        self.date = date
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? date
        self.startOfDay = start
        self.endOfDay = end
        _appointments = Query(
            filter: #Predicate<Appointment> { appt in
                appt.date >= start && appt.date < end
            },
            sort: [SortDescriptor(\Appointment.date, order: .forward)]
        )
    }

    var body: some View {
        List {
            if appointments.isEmpty {
                ContentUnavailableView("No Appointments", systemImage: "calendar.badge.exclamationmark", description: Text(date.formatted(date: .complete, time: .omitted)))
            } else {
                ForEach(appointments) { appt in
                    NavigationLink(value: appt.id) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appt.reason).font(.headline)
                            HStack {
                                Text(appt.date.formatted(date: .omitted, time: .shortened))
                                if let name = appt.patient?.fullName {
                                    Text("• \(name)")
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            NotificationManager.shared.cancelReminder(for: appt)
                            context.delete(appt)
                            try? context.save()
                        }
                    }
                }
            }
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.addAppointment) {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(for: Route.self) { route in
            if case .addAppointment = route {
                AppointmentFormView()
            }
        }
        .navigationDestination(for: PersistentIdentifier.self) { aid in
            if let appt = appointments.first(where: { $0.id == aid }) {
                AppointmentFormView(existing: appt)
            } else {
                Text("Appointment not found")
            }
        }
    }
}

// MARK: - Patient History (List + Detail)

private struct PatientHistoryListView: View {
    @Query(sort: [SortDescriptor<Patient>(\.fullName, order: .forward)])
    private var patients: [Patient]

    var body: some View {
        List {
            if patients.isEmpty {
                ContentUnavailableView("No Patients", systemImage: "person.crop.circle.badge.exclam", description: Text("Add patients to view history."))
            } else {
                ForEach(patients) { p in
                    let appts = p.appointments.sorted(by: { $0.date > $1.date })
                    let count = appts.count
                    let last = appts.first?.date

                    NavigationLink(value: p.id) {
                        HStack(spacing: 12) {
                            AvatarView(data: p.avatarData)
                                .frame(width: 36, height: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(p.fullName).font(.headline)
                                HStack(spacing: 6) {
                                    Text("\(count) appointments")
                                    if let last {
                                        Text("• Last: \(last.formatted(date: .abbreviated, time: .shortened))")
                                    }
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Patient History")
    }
}

// Helper destination that resolves a PersistentIdentifier to a Patient and shows detail
private struct PatientHistoryDetailDestination: View {
    @Query(sort: [SortDescriptor<Patient>(\.fullName, order: .forward)])
    private var patients: [Patient]

    let patientID: PersistentIdentifier

    var body: some View {
        if let patient = patients.first(where: { $0.id == patientID }) {
            PatientHistoryDetailView(patient: patient)
        } else {
            ContentUnavailableView("Patient Not Found", systemImage: "person.crop.circle.badge.exclam", description: Text("This patient may have been deleted."))
        }
    }
}

private struct PatientHistoryDetailView: View {
    let patient: Patient

    private var sortedAppointments: [Appointment] {
        patient.appointments.sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    AvatarView(data: patient.avatarData)
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(patient.fullName).font(.headline)
                        HStack(spacing: 8) {
                            if let age = patient.age { Text("Age: \(age)") }
                            Text(patient.gender.label)
                            if let phone = patient.phone, !phone.isEmpty {
                                Text("• \(phone)")
                            }
                        }
                        .foregroundStyle(.secondary)
                        if let tags = patient.tags, !tags.isEmpty {
                            Text("Tags: \(tags)").foregroundStyle(.secondary)
                        }
                        if let notes = patient.notes, !notes.isEmpty {
                            Text(notes).font(.subheadline)
                        }
                    }
                }
            }

            Section("Appointments") {
                if sortedAppointments.isEmpty {
                    Text("No appointments yet").foregroundStyle(.secondary)
                } else {
                    ForEach(sortedAppointments) { appt in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(.blue)
                                Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(appt.status.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            Text(appt.reason).font(.headline)
                            if let n = appt.notes, !n.isEmpty {
                                Text(n).font(.subheadline)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

// MARK: - AvatarView used in Patient History

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

/// Typed routes for the dashboard navigation stacks.
enum Route: Hashable {
    case patientList
    case addPatient
    case appointmentList
    case addAppointment
    case noteList
    case addNote
    case prescriptionList
    case addPrescription
    case historyList
}
