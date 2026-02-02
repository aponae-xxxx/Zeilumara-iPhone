//
//  AppState.swift
//  Zeilumara Time
//
//  Central state management for the app
//

import Foundation
import Combine

/// Central app state manager
@MainActor
class AppState: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var events: [ZeilumaraEvent] = []
    @Published var settings: ZeilumaraSettings = .default
    @Published var currentZeilumaraTime: ZeilumaraFullComponents
    @Published var notificationPermissionGranted: Bool = false
    
    // MARK: - Services
    
    let conversionService: TimeConversionService
    let persistenceService: PersistenceService
    let notificationService: NotificationService
    
    // MARK: - Timer
    
    private var timer: Timer?
    
    // MARK: - Initialization
    
    init() {
        // Load settings first (to get epoch)
        let loadedSettings: ZeilumaraSettings
        do {
            loadedSettings = try PersistenceService.shared.loadSettings()
            self.settings = loadedSettings
        } catch {
            print("Failed to load settings: \(error.localizedDescription)")
            loadedSettings = .default
            self.settings = .default
        }
        
        // Initialize services
        self.conversionService = TimeConversionService(baseTime: loadedSettings.epoch)
        self.persistenceService = PersistenceService.shared
        self.notificationService = NotificationService(conversionService: conversionService)
        
        // Set initial time
        self.currentZeilumaraTime = conversionService.toZeilumaraTime()
        
        // Load data
        loadEvents()
        checkNotificationPermission()
        
        // Start clock update timer
        startClockTimer()
    }
    
    // MARK: - Clock Management
    
    private func startClockTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateClock()
            }
        }
        timer?.tolerance = 0.1
    }
    
    private func updateClock() {
        currentZeilumaraTime = conversionService.toZeilumaraTime()
    }
    
    // MARK: - Event Management
    
    func loadEvents() {
        do {
            events = try persistenceService.loadEvents()
            print("Loaded \(events.count) events")
        } catch {
            print("Failed to load events: \(error.localizedDescription)")
            events = []
        }
    }
    
    func saveEvents() {
        do {
            try persistenceService.saveEvents(events)
            print("Saved \(events.count) events")
        } catch {
            print("Failed to save events: \(error.localizedDescription)")
        }
    }
    
    func addEvent(_ event: ZeilumaraEvent) {
        events.append(event)
        saveEvents()
        
        // Schedule notification
        if event.notificationEnabled {
            do {
                try notificationService.scheduleNotification(for: event)
            } catch {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func updateEvent(_ event: ZeilumaraEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
            
            // Reschedule notification
            do {
                try notificationService.rescheduleNotification(for: event)
            } catch {
                print("Failed to reschedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteEvent(_ event: ZeilumaraEvent) {
        events.removeAll { $0.id == event.id }
        saveEvents()
        notificationService.cancelNotification(for: event.id)
    }
    
    func deleteEvents(at offsets: IndexSet) {
        for index in offsets {
            notificationService.cancelNotification(for: events[index].id)
        }
        events.remove(atOffsets: offsets)
        saveEvents()
    }
    
    // MARK: - Settings Management
    
    func saveSettings() {
        do {
            try persistenceService.saveSettings(settings)
            print("Settings saved")
        } catch {
            print("Failed to save settings: \(error.localizedDescription)")
        }
    }
    
    func updateEpoch(_ newEpoch: Date) {
        settings.epoch = newEpoch
        saveSettings()
        
        // Update conversion service (requires recreating it)
        // Note: In production, you'd want to handle this more elegantly
        objectWillChange.send()
    }
    
    // MARK: - Notification Permission
    
    func checkNotificationPermission() {
        notificationService.checkPermission { [weak self] status in
            self?.notificationPermissionGranted = (status == .authorized)
        }
    }
    
    func requestNotificationPermission() {
        notificationService.requestPermission { [weak self] granted, error in
            self?.notificationPermissionGranted = granted
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Export / Import
    
    func exportEvents() -> Data? {
        do {
            return try persistenceService.exportEvents(events)
        } catch {
            print("Failed to export events: \(error.localizedDescription)")
            return nil
        }
    }
    
    func importEvents(from data: Data) {
        do {
            let importedEvents = try persistenceService.importEvents(from: data)
            events.append(contentsOf: importedEvents)
            saveEvents()
            
            // Schedule notifications for imported events
            try notificationService.rescheduleAllNotifications(for: events)
        } catch {
            print("Failed to import events: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        timer?.invalidate()
    }
}
