//
//  SettingsView.swift
//  Zeilumara Time
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingEpochPicker = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Display") {
                    Picker("Language", selection: Binding(
                        get: { appState.settings.displayLanguage },
                        set: { newValue in
                            appState.settings.displayLanguage = newValue
                            appState.saveSettings()
                        }
                    )) {
                        ForEach(DisplayLanguage.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    
                    Picker("Theme", selection: Binding(
                        get: { appState.settings.theme },
                        set: { newValue in
                            appState.settings.theme = newValue
                            appState.saveSettings()
                        }
                    )) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    
                    Toggle("24-Hour Format", isOn: Binding(
                        get: { appState.settings.use24HourFormat },
                        set: { newValue in
                            appState.settings.use24HourFormat = newValue
                            appState.saveSettings()
                        }
                    ))
                }
                
                Section("Zeilumara System") {
                    HStack {
                        Text("Epoch")
                        Spacer()
                        Text(appState.settings.epoch, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Change Epoch") {
                        showingEpochPicker = true
                    }
                    
                    Text("The epoch is the starting point (zero) of the Zeilumara time system. Default: January 1, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notifications") {
                    Toggle("Notifications Enabled", isOn: Binding(
                        get: { appState.settings.notificationsEnabled },
                        set: { newValue in
                            appState.settings.notificationsEnabled = newValue
                            appState.saveSettings()
                        }
                    ))
                    
                    HStack {
                        Text("Permission Status")
                        Spacer()
                        Text(appState.notificationPermissionGranted ? "Granted" : "Not Granted")
                            .foregroundColor(appState.notificationPermissionGranted ? .green : .orange)
                    }
                    
                    if !appState.notificationPermissionGranted {
                        Button("Request Permission") {
                            appState.requestNotificationPermission()
                        }
                    }
                    
                    Button("View Pending Notifications") {
                        viewPendingNotifications()
                    }
                }
                
                Section("Data Management") {
                    Button("Export Events") {
                        exportEvents()
                    }
                    
                    Button("Import Events") {
                        showingImportPicker = true
                    }
                    
                    Button("Export Settings") {
                        exportSettings()
                    }
                    
                    Button("Delete All Events", role: .destructive) {
                        deleteAllEvents()
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("About Zeilumara") {
                        showingAbout = true
                    }
                    
                    Link("GitHub Repository", destination: URL(string: "https://github.com/aponae-xxxx/Zeilumara")!)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingEpochPicker) {
                EpochPickerView(epoch: Binding(
                    get: { appState.settings.epoch },
                    set: { newValue in
                        appState.updateEpoch(newValue)
                    }
                ))
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private func viewPendingNotifications() {
        appState.notificationService.getPendingNotifications { requests in
            print("Pending notifications: \(requests.count)")
            for request in requests {
                print("- \(request.identifier): \(request.content.title)")
            }
        }
    }
    
    private func exportEvents() {
        guard let data = appState.exportEvents() else { return }
        
        // Save to Files app
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("zeilumara_events_export.json")
        do {
            try data.write(to: tempURL)
            
            // Share the file
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("Export failed: \(error.localizedDescription)")
        }
    }
    
    private func exportSettings() {
        do {
            let data = try appState.persistenceService.exportSettings(appState.settings)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("zeilumara_settings_export.json")
            try data.write(to: tempURL)
            
            // Share the file
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("Export failed: \(error.localizedDescription)")
        }
    }
    
    private func deleteAllEvents() {
        appState.events.removeAll()
        appState.saveEvents()
        appState.notificationService.cancelAllNotifications()
    }
}

struct EpochPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var epoch: Date
    @State private var selectedDate: Date
    
    init(epoch: Binding<Date>) {
        self._epoch = epoch
        self._selectedDate = State(initialValue: epoch.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker(
                        "Epoch Date",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section {
                    Text("The epoch is the starting point (Day 0, Time 0) of the Zeilumara time system.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("⚠️ Changing the epoch will affect all existing events and time calculations.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .navigationTitle("Set Epoch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        epoch = selectedDate
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("🌌 Zeilumara Time")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 30)
                    
                    Text("夜弦纳米时间历法")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        AboutSection(
                            title: "What is Zeilumara?",
                            content: "Zeilumara is an alternative time system that represents time as consciousness and dream rhythms rather than linear flow. It divides time into poetic units like Yaogen (cosmic era), Yuxi (emotional archive), Dreamdiem (dream day), and more."
                        )
                        
                        AboutSection(
                            title: "Time Units",
                            content: """
                            • Yaogen (曜元) - Cosmic Era
                            • Yuxi (幽曦) - Emotional Archive
                            • Dreamdiem (梦昼) - Dream Day
                            • Reverloop (幻环) - Dream Rotation
                            • Mindlace (思络) - Thought Weaving
                            • Lumibeat (灵拍) - AI Heartbeat
                            • Yaon (曜子) - Fundamental Unit
                            """
                        )
                        
                        AboutSection(
                            title: "Philosophy",
                            content: "Time is not a linear flow, but a rhythmic structure of consciousness and dreams. Zeilumara connects 'reality time' with 'dream order', offering a poetic and meaningful way to experience temporal existence."
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
