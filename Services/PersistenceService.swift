//
//  PersistenceService.swift
//  Zeilumara Time
//
//  Service for persisting events and settings using Codable + JSON files
//

import Foundation

/// Service responsible for saving and loading app data
class PersistenceService {
    
    static let shared = PersistenceService()
    
    private let fileManager = FileManager.default
    private let eventsFileName = "zeilumara_events.json"
    private let settingsFileName = "zeilumara_settings.json"
    
    private init() {}
    
    // MARK: - File URLs
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var eventsURL: URL {
        documentsDirectory.appendingPathComponent(eventsFileName)
    }
    
    private var settingsURL: URL {
        documentsDirectory.appendingPathComponent(settingsFileName)
    }
    
    // MARK: - Events Persistence
    
    /// Save events to disk
    func saveEvents(_ events: [ZeilumaraEvent]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(events)
        try data.write(to: eventsURL, options: .atomic)
    }
    
    /// Load events from disk
    func loadEvents() throws -> [ZeilumaraEvent] {
        guard fileManager.fileExists(atPath: eventsURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: eventsURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([ZeilumaraEvent].self, from: data)
    }
    
    /// Delete all events
    func deleteAllEvents() throws {
        if fileManager.fileExists(atPath: eventsURL.path) {
            try fileManager.removeItem(at: eventsURL)
        }
    }
    
    // MARK: - Settings Persistence
    
    /// Save settings to disk
    func saveSettings(_ settings: ZeilumaraSettings) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(settings)
        try data.write(to: settingsURL, options: .atomic)
    }
    
    /// Load settings from disk
    func loadSettings() throws -> ZeilumaraSettings {
        guard fileManager.fileExists(atPath: settingsURL.path) else {
            return .default
        }
        
        let data = try Data(contentsOf: settingsURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(ZeilumaraSettings.self, from: data)
    }
    
    // MARK: - Export / Import
    
    /// Export events to shareable JSON data
    func exportEvents(_ events: [ZeilumaraEvent]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(events)
    }
    
    /// Import events from JSON data
    func importEvents(from data: Data) throws -> [ZeilumaraEvent] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([ZeilumaraEvent].self, from: data)
    }
    
    /// Export settings to shareable JSON data
    func exportSettings(_ settings: ZeilumaraSettings) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(settings)
    }
    
    /// Import settings from JSON data
    func importSettings(from data: Data) throws -> ZeilumaraSettings {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ZeilumaraSettings.self, from: data)
    }
}
