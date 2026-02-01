//
//  ZeilumaraTime.swift
//  Zeilumara Time
//
//  Core data model for Zeilumara time representation
//

import Foundation

/// Represents a point in time in the Zeilumara time system
struct ZeilumaraTime: Codable, Equatable, Hashable {
    /// Zeilumara seconds since the epoch
    var zSecondsSinceEpoch: Double
    
    init(zSecondsSinceEpoch: Double) {
        self.zSecondsSinceEpoch = zSecondsSinceEpoch
    }
    
    /// Initialize from Zeilumara components
    init(day: Int, hour: Int, minute: Int, second: Double, config: ZeilumaraConfig) {
        let totalSeconds = Double(day) * config.zSecondsPerDay
            + Double(hour) * config.zSecondsPerHour
            + Double(minute) * config.zSecondsPerMinute
            + second
        self.zSecondsSinceEpoch = totalSeconds
    }
    
    /// Get components from total seconds
    func components(config: ZeilumaraConfig) -> ZeilumaraComponents {
        var remaining = zSecondsSinceEpoch
        
        let days = Int(remaining / config.zSecondsPerDay)
        remaining -= Double(days) * config.zSecondsPerDay
        
        let hours = Int(remaining / config.zSecondsPerHour)
        remaining -= Double(hours) * config.zSecondsPerHour
        
        let minutes = Int(remaining / config.zSecondsPerMinute)
        remaining -= Double(minutes) * config.zSecondsPerMinute
        
        let seconds = remaining
        
        return ZeilumaraComponents(
            day: days,
            hour: hours,
            minute: minutes,
            second: seconds
        )
    }
}

/// Components of Zeilumara time for display
struct ZeilumaraComponents: Equatable {
    var day: Int
    var hour: Int
    var minute: Int
    var second: Double
    
    /// Formatted string for display
    func formatted() -> String {
        String(format: "Day %d, %02d:%02d:%05.2f", day, hour, minute, second)
    }
    
    /// Short format without day
    func shortFormatted() -> String {
        String(format: "%02d:%02d:%05.2f", hour, minute, second)
    }
}

/// Configuration for Zeilumara time structure
struct ZeilumaraConfig: Codable, Equatable {
    var zSecondsPerMinute: Double = 100
    var zMinutesPerHour: Double = 100
    var zHoursPerDay: Double = 10
    
    var zSecondsPerHour: Double {
        zSecondsPerMinute * zMinutesPerHour
    }
    
    var zSecondsPerDay: Double {
        zSecondsPerHour * zHoursPerDay
    }
    
    static let `default` = ZeilumaraConfig()
}
