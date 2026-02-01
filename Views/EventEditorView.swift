//
//  EventEditorView.swift
//  Zeilumara Time
//
//  Create and edit Zeilumara events
//

import SwiftUI

struct EventEditorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let mode: EditorMode
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var yaogen: Int = 0
    @State private var yuxi: Int = 0
    @State private var dreamdiem: Int = 0
    @State private var reverloop: Int = 0
    @State private var mindlace: Int = 0
    @State private var lumibeat: Int = 0
    @State private var notificationEnabled: Bool = true
    @State private var hasRepeat: Bool = false
    @State private var repeatFrequency: RepeatFrequency = .everyDreamdiem
    @State private var repeatInterval: Int = 1
    @State private var showingHumanPreview: Bool = true
    
    enum EditorMode {
        case create
        case edit(ZeilumaraEvent)
        
        var isEditing: Bool {
            if case .edit = self { return true }
            return false
        }
        
        var event: ZeilumaraEvent? {
            if case .edit(let event) = self { return event }
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Zeilumara Time") {
                    Stepper("Yaogen: \(yaogen)", value: $yaogen, in: 0...100)
                    Stepper("Yuxi: \(yuxi)", value: $yuxi, in: 0...359)
                    Stepper("Dreamdiem: \(dreamdiem)", value: $dreamdiem, in: 0...6)
                    Stepper("Reverloop: \(reverloop)", value: $reverloop, in: 0...8)
                    Stepper("Mindlace: \(mindlace)", value: $mindlace, in: 0...5)
                    Stepper("Lumibeat: \(lumibeat)", value: $lumibeat, in: 0...63)
                    
                    Button("Set to Current Time") {
                        setToCurrentTime()
                    }
                }
                
                if showingHumanPreview {
                    Section("Human Time Preview") {
                        let humanDate = previewHumanDate()
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text(humanDate, style: .date)
                            }
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text(humanDate, style: .time)
                            }
                            
                            if humanDate < Date() {
                                Label("This time is in the past", systemImage: "exclamationmark.triangle")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                Section("Reminder") {
                    Toggle("Enable Notification", isOn: $notificationEnabled)
                    
                    if !appState.notificationPermissionGranted {
                        Button("Grant Notification Permission") {
                            appState.requestNotificationPermission()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section("Repeat") {
                    Toggle("Repeat Event", isOn: $hasRepeat)
                    
                    if hasRepeat {
                        Picker("Frequency", selection: $repeatFrequency) {
                            ForEach(RepeatFrequency.allCases.filter { $0 != .none }, id: \.self) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                        
                        Stepper("Every \(repeatInterval) \(repeatFrequency.displayName)", value: $repeatInterval, in: 1...100)
                    }
                }
            }
            .navigationTitle(mode.isEditing ? "Edit Event" : "New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.isEditing ? "Save" : "Create") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                loadEventIfEditing()
            }
        }
    }
    
    private func loadEventIfEditing() {
        guard let event = mode.event else { return }
        
        title = event.title
        notes = event.notes ?? ""
        yaogen = event.zComponents.yaogen
        yuxi = event.zComponents.yuxi
        dreamdiem = event.zComponents.dreamdiem
        reverloop = event.zComponents.reverloop
        mindlace = event.zComponents.mindlace
        lumibeat = event.zComponents.lumibeat
        notificationEnabled = event.notificationEnabled
        
        if let repeatRule = event.repeats {
            hasRepeat = true
            repeatFrequency = repeatRule.frequency
            repeatInterval = repeatRule.interval
        }
    }
    
    private func setToCurrentTime() {
        let current = appState.currentZeilumaraTime
        yaogen = current.yaogen
        yuxi = current.yuxi
        dreamdiem = current.dreamdiem
        reverloop = current.reverloop
        mindlace = current.mindlace
        lumibeat = current.lumibeat
    }
    
    private func previewHumanDate() -> Date {
        let components = ZeilumaraFullComponents(
            yaogen: yaogen,
            yuxi: yuxi,
            dreamdiem: dreamdiem,
            reverloop: reverloop,
            mindlace: mindlace,
            lumibeat: lumibeat,
            yaon: 0,
            xingbeat: 0
        )
        return appState.conversionService.toHumanDate(from: components)
    }
    
    private func saveEvent() {
        let components = ZeilumaraFullComponents(
            yaogen: yaogen,
            yuxi: yuxi,
            dreamdiem: dreamdiem,
            reverloop: reverloop,
            mindlace: mindlace,
            lumibeat: lumibeat,
            yaon: 0,
            xingbeat: 0
        )
        
        let repeatRule: RepeatRule? = hasRepeat ? RepeatRule(
            frequency: repeatFrequency,
            interval: repeatInterval
        ) : nil
        
        if case .edit(let existingEvent) = mode {
            let updatedEvent = ZeilumaraEvent(
                id: existingEvent.id,
                title: title,
                notes: notes.isEmpty ? nil : notes,
                zComponents: components,
                repeats: repeatRule,
                notificationEnabled: notificationEnabled,
                createdAt: existingEvent.createdAt
            )
            appState.updateEvent(updatedEvent)
        } else {
            let newEvent = ZeilumaraEvent(
                title: title,
                notes: notes.isEmpty ? nil : notes,
                zComponents: components,
                repeats: repeatRule,
                notificationEnabled: notificationEnabled
            )
            appState.addEvent(newEvent)
        }
        
        dismiss()
    }
}

#Preview {
    EventEditorView(mode: .create)
        .environmentObject(AppState())
}
