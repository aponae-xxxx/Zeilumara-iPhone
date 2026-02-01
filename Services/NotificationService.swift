//
//  NotificationService.swift
//  Zeilumara Time
//
//  Service for scheduling local notifications for Zeilumara events
//

import Foundation
import UserNotifications

/// Service responsible for scheduling and managing event notifications
class NotificationService {
    
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    private let conversionService: TimeConversionService
    
    init(conversionService: TimeConversionService = TimeConversionService()) {
        self.conversionService = conversionService
    }
    
    // MARK: - Permission Management
    
    /// Request notification permission from user
    func requestPermission(completion: @escaping (Bool, Error?) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }
    
    /// Check current notification authorization status
    func checkPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Scheduling Notifications
    
    /// Schedule a notification for a Zeilumara event
    func scheduleNotification(for event: ZeilumaraEvent) throws {
        guard event.notificationEnabled else { return }
        
        // Convert Zeilumara time to human Date
        let fireDate = conversionService.toHumanDate(from: event.zComponents)
        
        // Don't schedule notifications for past events
        guard fireDate > Date() else {
            print("Skipping notification for past event: \(event.title)")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = event.notes ?? "Zeilumara event reminder"
        content.sound = .default
        content.categoryIdentifier = "ZEILUMARA_EVENT"
        
        // Add Zeilumara time in user info
        content.userInfo = [
            "eventId": event.id.uuidString,
            "zTime": event.zComponents.compactFormat()
        ]
        
        // Create trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: event.repeats != nil
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // Schedule
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification for '\(event.title)' at \(fireDate)")
            }
        }
        
        // Handle repeats for Zeilumara-based frequencies
        if let repeatRule = event.repeats, repeatRule.frequency.isZeilumaraUnit {
            try scheduleRepeatingZeilumaraNotifications(for: event, repeatRule: repeatRule)
        }
    }
    
    /// Schedule multiple notifications for Zeilumara-based repeat patterns
    /// (since iOS doesn't natively support custom repeat intervals)
    private func scheduleRepeatingZeilumaraNotifications(
        for event: ZeilumaraEvent,
        repeatRule: RepeatRule
    ) throws {
        // Schedule up to 50 future occurrences (iOS limit is 64 pending notifications total)
        let maxOccurrences = 50
        var currentComponents = event.zComponents
        
        for occurrence in 1...maxOccurrences {
            // Calculate next occurrence
            currentComponents = nextOccurrence(
                from: currentComponents,
                frequency: repeatRule.frequency,
                interval: repeatRule.interval
            )
            
            let fireDate = conversionService.toHumanDate(from: currentComponents)
            
            // Stop if past end date
            if let endDate = repeatRule.endDate, fireDate > endDate {
                break
            }
            
            // Stop if more than 1 year in future
            if fireDate.timeIntervalSinceNow > 365 * 24 * 60 * 60 {
                break
            }
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = event.title
            content.body = event.notes ?? "Zeilumara event reminder"
            content.sound = .default
            content.categoryIdentifier = "ZEILUMARA_EVENT"
            content.userInfo = [
                "eventId": event.id.uuidString,
                "zTime": currentComponents.compactFormat(),
                "occurrence": occurrence
            ]
            
            // Create trigger
            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Create request with unique identifier
            let identifier = "\(event.id.uuidString)_repeat_\(occurrence)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling repeat notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Calculate next occurrence based on frequency
    private func nextOccurrence(
        from components: ZeilumaraFullComponents,
        frequency: RepeatFrequency,
        interval: Int
    ) -> ZeilumaraFullComponents {
        var new = components
        
        switch frequency {
        case .everyLumibeat:
            new.lumibeat += interval
            if new.lumibeat >= Int(ZeilumaraConstants.lumibeatPerMindlace) {
                new.mindlace += new.lumibeat / Int(ZeilumaraConstants.lumibeatPerMindlace)
                new.lumibeat %= Int(ZeilumaraConstants.lumibeatPerMindlace)
            }
            
        case .everyMindlace:
            new.mindlace += interval
            if new.mindlace >= Int(ZeilumaraConstants.mindlacePerReverloop) {
                new.reverloop += new.mindlace / Int(ZeilumaraConstants.mindlacePerReverloop)
                new.mindlace %= Int(ZeilumaraConstants.mindlacePerReverloop)
            }
            
        case .everyReverloop:
            new.reverloop += interval
            if new.reverloop >= Int(ZeilumaraConstants.reverlooPerDreamdiem) {
                new.dreamdiem += new.reverloop / Int(ZeilumaraConstants.reverlooPerDreamdiem)
                new.reverloop %= Int(ZeilumaraConstants.reverlooPerDreamdiem)
            }
            
        case .everyDreamdiem:
            new.dreamdiem += interval
            if new.dreamdiem >= Int(ZeilumaraConstants.dreamdiemPerYuxi) {
                new.yuxi += new.dreamdiem / Int(ZeilumaraConstants.dreamdiemPerYuxi)
                new.dreamdiem %= Int(ZeilumaraConstants.dreamdiemPerYuxi)
            }
            
        case .everyYuxi:
            new.yuxi += interval
            if new.yuxi >= Int(ZeilumaraConstants.yuxiPerYaogen) {
                new.yaogen += new.yuxi / Int(ZeilumaraConstants.yuxiPerYaogen)
                new.yuxi %= Int(ZeilumaraConstants.yuxiPerYaogen)
            }
            
        case .daily, .weekly, .monthly, .none:
            // These are handled by iOS native repeat
            break
        }
        
        return new
    }
    
    // MARK: - Managing Notifications
    
    /// Cancel notification for a specific event
    func cancelNotification(for eventId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [eventId.uuidString])
        
        // Also remove repeat occurrences
        center.getPendingNotificationRequests { requests in
            let repeatIds = requests
                .filter { $0.identifier.starts(with: "\(eventId.uuidString)_repeat_") }
                .map { $0.identifier }
            
            if !repeatIds.isEmpty {
                self.center.removePendingNotificationRequests(withIdentifiers: repeatIds)
            }
        }
    }
    
    /// Cancel all notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// Get list of pending notification requests
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    /// Reschedule notification (useful after editing an event)
    func rescheduleNotification(for event: ZeilumaraEvent) throws {
        cancelNotification(for: event.id)
        try scheduleNotification(for: event)
    }
    
    /// Reschedule all notifications for a list of events
    func rescheduleAllNotifications(for events: [ZeilumaraEvent]) throws {
        cancelAllNotifications()
        for event in events {
            try scheduleNotification(for: event)
        }
    }
}
