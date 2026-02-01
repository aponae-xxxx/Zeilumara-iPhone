//
//  ZeilumaraEvent.swift
//  Zeilumara Time
//
//  Data model for Zeilumara scheduled events
//

import Foundation

/// Represents a scheduled event in Zeilumara time
struct ZeilumaraEvent: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var notes: String?
    var zComponents: ZeilumaraFullComponents
    var repeats: RepeatRule?
    var notificationEnabled: Bool
    var createdAt: Date
    var calendarEventId: String? // For EventKit integration
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        zComponents: ZeilumaraFullComponents,
        repeats: RepeatRule? = nil,
        notificationEnabled: Bool = true,
        createdAt: Date = Date(),
        calendarEventId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.zComponents = zComponents
        self.repeats = repeats
        self.notificationEnabled = notificationEnabled
        self.createdAt = createdAt
        self.calendarEventId = calendarEventId
    }
    
    /// Get the corresponding human date for this event
    func humanDate(using service: TimeConversionService) -> Date {
        return service.toHumanDate(from: zComponents)
    }
    
    /// Check if this event is in the past
    func isPast(using service: TimeConversionService) -> Bool {
        return humanDate(using: service) < Date()
    }
    
    /// Check if this event is today (in human time)
    func isToday(using service: TimeConversionService) -> Bool {
        let eventDate = humanDate(using: service)
        return Calendar.current.isDateInToday(eventDate)
    }
}

/// Repeat rules for recurring events
struct RepeatRule: Codable, Equatable {
    var frequency: RepeatFrequency
    var interval: Int // Every N units
    var endDate: Date?
    
    init(frequency: RepeatFrequency, interval: Int = 1, endDate: Date? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
    }
}

/// Frequency options for repeating events
enum RepeatFrequency: String, Codable, CaseIterable {
    case none = "None"
    case everyLumibeat = "Every Lumibeat"
    case everyMindlace = "Every Mindlace"
    case everyReverloop = "Every Reverloop"
    case everyDreamdiem = "Every Dreamdiem"
    case everyYuxi = "Every Yuxi"
    case daily = "Daily (Human)"
    case weekly = "Weekly (Human)"
    case monthly = "Monthly (Human)"
    
    var displayName: String {
        return self.rawValue
    }
    
    var isZeilumaraUnit: Bool {
        switch self {
        case .everyLumibeat, .everyMindlace, .everyReverloop, .everyDreamdiem, .everyYuxi:
            return true
        default:
            return false
        }
    }
}

/// Settings for the Zeilumara app
struct ZeilumaraSettings: Codable {
    var epoch: Date
    var displayLanguage: DisplayLanguage
    var use24HourFormat: Bool
    var notificationsEnabled: Bool
    var calendarIntegrationEnabled: Bool
    var theme: AppTheme
    
    init(
        epoch: Date = Date(timeIntervalSince1970: 1735689600),
        displayLanguage: DisplayLanguage = .romanized,
        use24HourFormat: Bool = true,
        notificationsEnabled: Bool = true,
        calendarIntegrationEnabled: Bool = false,
        theme: AppTheme = .auto
    ) {
        self.epoch = epoch
        self.displayLanguage = displayLanguage
        self.use24HourFormat = use24HourFormat
        self.notificationsEnabled = notificationsEnabled
        self.calendarIntegrationEnabled = calendarIntegrationEnabled
        self.theme = theme
    }
    
    static let `default` = ZeilumaraSettings()
}

enum DisplayLanguage: String, Codable, CaseIterable {
    case chinese = "Chinese (中文)"
    case romanized = "Romanized"
    case both = "Both"
    
    var displayName: String { rawValue }
}

enum AppTheme: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case auto = "Auto"
    
    var displayName: String { rawValue }
}
