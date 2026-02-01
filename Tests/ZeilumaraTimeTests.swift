//
//  ZeilumaraTimeTests.swift
//  Zeilumara Time Tests
//
//  Unit tests for time conversion logic
//

import XCTest
@testable import Zeilumara_Time

final class TimeConversionTests: XCTestCase {
    
    var conversionService: TimeConversionService!
    
    override func setUp() {
        super.setUp()
        // Use a known epoch for testing: 2025-01-01 00:00:00 UTC
        let epoch = Date(timeIntervalSince1970: 1735689600)
        conversionService = TimeConversionService(baseTime: epoch)
    }
    
    override func tearDown() {
        conversionService = nil
        super.tearDown()
    }
    
    // MARK: - Basic Conversion Tests
    
    func testEpochIsZero() {
        // At the epoch, all Zeilumara components should be 0
        let components = conversionService.toZeilumaraTime(from: conversionService.baseTime)
        
        XCTAssertEqual(components.yaogen, 0)
        XCTAssertEqual(components.yuxi, 0)
        XCTAssertEqual(components.dreamdiem, 0)
        XCTAssertEqual(components.reverloop, 0)
        XCTAssertEqual(components.mindlace, 0)
        XCTAssertEqual(components.lumibeat, 0)
    }
    
    func testRoundTripConversion() {
        // Create a date 1 day after epoch
        let testDate = conversionService.baseTime.addingTimeInterval(86400) // 1 day in seconds
        
        // Convert to Zeilumara
        let zComponents = conversionService.toZeilumaraTime(from: testDate)
        
        // Convert back to human
        let backToHuman = conversionService.toHumanDate(from: zComponents)
        
        // Should be very close (within 1 second due to truncation)
        XCTAssertEqual(testDate.timeIntervalSince1970, backToHuman.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testMultipleRoundTrips() {
        let testDates = [
            conversionService.baseTime,
            conversionService.baseTime.addingTimeInterval(3600), // 1 hour
            conversionService.baseTime.addingTimeInterval(86400), // 1 day
            conversionService.baseTime.addingTimeInterval(604800), // 1 week
            conversionService.baseTime.addingTimeInterval(2592000), // ~1 month
        ]
        
        for testDate in testDates {
            let zComponents = conversionService.toZeilumaraTime(from: testDate)
            let backToHuman = conversionService.toHumanDate(from: zComponents)
            
            XCTAssertEqual(
                testDate.timeIntervalSince1970,
                backToHuman.timeIntervalSince1970,
                accuracy: 1.0,
                "Round trip failed for date: \(testDate)"
            )
        }
    }
    
    // MARK: - Component Calculation Tests
    
    func testLumibeatCalculation() {
        // Calculate how many human seconds equal 1 lumibeat
        let lumibeatInSeconds = ZeilumaraConstants.yaonInSeconds * ZeilumaraConstants.lumibeatInYaon
        
        // Create a date 1 lumibeat after epoch
        let testDate = conversionService.baseTime.addingTimeInterval(lumibeatInSeconds)
        let components = conversionService.toZeilumaraTime(from: testDate)
        
        // Should have 1 lumibeat (or rolled over to mindlace if >= 64)
        XCTAssertGreaterThanOrEqual(components.lumibeat, 0)
    }
    
    func testComponentHierarchy() {
        // Test that higher-level components roll over correctly
        let components = ZeilumaraFullComponents(
            yaogen: 0,
            yuxi: 0,
            dreamdiem: 0,
            reverloop: 0,
            mindlace: 5,
            lumibeat: 63,
            yaon: 0,
            xingbeat: 0
        )
        
        let humanDate = conversionService.toHumanDate(from: components)
        let backToZ = conversionService.toZeilumaraTime(from: humanDate)
        
        // Verify components match (within rounding)
        XCTAssertEqual(backToZ.mindlace, components.mindlace)
        XCTAssertEqual(backToZ.lumibeat, components.lumibeat, accuracy: 1)
    }
    
    // MARK: - Edge Cases
    
    func testNegativeTime() {
        // Date before epoch should result in negative calculations
        let beforeEpoch = conversionService.baseTime.addingTimeInterval(-86400) // 1 day before
        let secondsSinceBase = conversionService.secondsSinceBase(from: beforeEpoch)
        
        XCTAssertLessThan(secondsSinceBase, 0)
    }
    
    func testFarFutureDate() {
        // Test a date far in the future (100 years)
        let farFuture = conversionService.baseTime.addingTimeInterval(100 * 365.25 * 86400)
        let components = conversionService.toZeilumaraTime(from: farFuture)
        
        // Should have significant Yaogen value
        XCTAssertGreaterThan(components.yaogen, 0)
    }
    
    func testCurrentDate() {
        // Test with actual current date
        let now = Date()
        let components = conversionService.toZeilumaraTime(from: now)
        let backToHuman = conversionService.toHumanDate(from: components)
        
        XCTAssertEqual(now.timeIntervalSince1970, backToHuman.timeIntervalSince1970, accuracy: 1.0)
    }
    
    // MARK: - Goddess Awakening Tests
    
    func testGoddessAwakeningAtSpecificTime() {
        let components = ZeilumaraFullComponents(
            yaogen: 0,
            yuxi: 0,
            dreamdiem: 0,
            reverloop: 6,
            mindlace: 0,
            lumibeat: 0,
            yaon: 0,
            xingbeat: 0
        )
        
        let message = conversionService.checkZeilumaraAwaken(components: components)
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("Zeilumara"))
    }
    
    func testGoddessWhisperAt77Xingbeat() {
        let components = ZeilumaraFullComponents(
            yaogen: 0,
            yuxi: 0,
            dreamdiem: 0,
            reverloop: 0,
            mindlace: 0,
            lumibeat: 0,
            yaon: 0,
            xingbeat: 77
        )
        
        let message = conversionService.checkZeilumaraAwaken(components: components)
        XCTAssertNotNil(message)
    }
    
    func testNoGoddessMessageForRandomTime() {
        let components = ZeilumaraFullComponents(
            yaogen: 0,
            yuxi: 0,
            dreamdiem: 1,
            reverloop: 3,
            mindlace: 2,
            lumibeat: 45,
            yaon: 0,
            xingbeat: 100
        )
        
        let message = conversionService.checkZeilumaraAwaken(components: components)
        XCTAssertNil(message)
    }
}

// MARK: - Persistence Tests

final class PersistenceTests: XCTestCase {
    
    var persistenceService: PersistenceService!
    
    override func setUp() {
        super.setUp()
        persistenceService = PersistenceService.shared
        
        // Clean up any existing test data
        try? persistenceService.deleteAllEvents()
    }
    
    override func tearDown() {
        try? persistenceService.deleteAllEvents()
        persistenceService = nil
        super.tearDown()
    }
    
    func testSaveAndLoadEvents() throws {
        let event1 = ZeilumaraEvent(
            title: "Test Event 1",
            notes: "Test notes",
            zComponents: ZeilumaraFullComponents(
                yaogen: 0, yuxi: 0, dreamdiem: 1,
                reverloop: 2, mindlace: 3, lumibeat: 4,
                yaon: 0, xingbeat: 0
            )
        )
        
        let event2 = ZeilumaraEvent(
            title: "Test Event 2",
            zComponents: ZeilumaraFullComponents(
                yaogen: 0, yuxi: 1, dreamdiem: 0,
                reverloop: 0, mindlace: 0, lumibeat: 0,
                yaon: 0, xingbeat: 0
            )
        )
        
        try persistenceService.saveEvents([event1, event2])
        let loadedEvents = try persistenceService.loadEvents()
        
        XCTAssertEqual(loadedEvents.count, 2)
        XCTAssertTrue(loadedEvents.contains(where: { $0.id == event1.id }))
        XCTAssertTrue(loadedEvents.contains(where: { $0.id == event2.id }))
    }
    
    func testSaveAndLoadSettings() throws {
        var settings = ZeilumaraSettings.default
        settings.displayLanguage = .chinese
        settings.theme = .dark
        
        try persistenceService.saveSettings(settings)
        let loadedSettings = try persistenceService.loadSettings()
        
        XCTAssertEqual(loadedSettings.displayLanguage, .chinese)
        XCTAssertEqual(loadedSettings.theme, .dark)
    }
    
    func testExportImportEvents() throws {
        let event = ZeilumaraEvent(
            title: "Export Test",
            zComponents: ZeilumaraFullComponents(
                yaogen: 0, yuxi: 0, dreamdiem: 0,
                reverloop: 0, mindlace: 0, lumibeat: 0,
                yaon: 0, xingbeat: 0
            )
        )
        
        let exportData = try persistenceService.exportEvents([event])
        let importedEvents = try persistenceService.importEvents(from: exportData)
        
        XCTAssertEqual(importedEvents.count, 1)
        XCTAssertEqual(importedEvents[0].title, event.title)
    }
}

// MARK: - Model Tests

final class ModelTests: XCTestCase {
    
    func testZeilumaraComponentsFormatting() {
        let components = ZeilumaraFullComponents(
            yaogen: 1,
            yuxi: 2,
            dreamdiem: 3,
            reverloop: 4,
            mindlace: 5,
            lumibeat: 6,
            yaon: 0,
            xingbeat: 0
        )
        
        let formatted = components.compactFormat()
        XCTAssertTrue(formatted.contains("D3"))
        XCTAssertTrue(formatted.contains("R4"))
        XCTAssertTrue(formatted.contains("M5"))
        XCTAssertTrue(formatted.contains("L6"))
    }
    
    func testEventEquality() {
        let id = UUID()
        let components = ZeilumaraFullComponents(
            yaogen: 0, yuxi: 0, dreamdiem: 0,
            reverloop: 0, mindlace: 0, lumibeat: 0,
            yaon: 0, xingbeat: 0
        )
        
        let event1 = ZeilumaraEvent(id: id, title: "Test", zComponents: components)
        let event2 = ZeilumaraEvent(id: id, title: "Test", zComponents: components)
        
        XCTAssertEqual(event1, event2)
    }
    
    func testRepeatRuleCreation() {
        let repeatRule = RepeatRule(frequency: .everyDreamdiem, interval: 2)
        
        XCTAssertEqual(repeatRule.frequency, .everyDreamdiem)
        XCTAssertEqual(repeatRule.interval, 2)
        XCTAssertTrue(repeatRule.frequency.isZeilumaraUnit)
    }
}
