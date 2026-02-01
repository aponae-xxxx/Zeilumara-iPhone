# Zeilumara iOS Development Guide

Complete developer guide for building, testing, and deploying the Zeilumara Time iPhone app.

## Table of Contents

1. [Setup](#setup)
2. [Project Configuration](#project-configuration)
3. [Building](#building)
4. [Testing](#testing)
5. [Debugging](#debugging)
6. [Deployment](#deployment)
7. [CI/CD](#cicd)
8. [Troubleshooting](#troubleshooting)

---

## Setup

### Prerequisites

**Required:**
- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Apple Developer account (for device testing)

**Recommended:**
- Git 2.30+
- Homebrew (for additional tools)
- Physical iPhone (for notification testing)

### Initial Setup

1. **Install Xcode**:
```bash
# Download from App Store or:
xcode-select --install
```

2. **Clone Repository**:
```bash
git clone https://github.com/your-username/zeilumara-ios.git
cd zeilumara-ios/swift_time
```

3. **Verify Swift Version**:
```bash
swift --version
# Should be 5.9 or later
```

### Creating the Xcode Project

If starting from these source files, create an Xcode project:

1. Open Xcode
2. File → New → Project
3. Select "App" under iOS
4. Configure:
   - Product Name: `Zeilumara Time`
   - Team: Your Apple Developer team
   - Organization Identifier: `com.yourorg`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None (we handle it manually)
5. Save to `e:\project\swift_time`

6. **Add Files**:
   - Drag folders into Xcode navigator:
     - Models/
     - Services/
     - Views/
     - Tests/

7. **Configure Target**:
   - Select project in navigator
   - General tab:
     - Deployment Target: iOS 16.0
     - Supported Destinations: iPhone
   - Signing & Capabilities:
     - Automatically manage signing: ON
     - Team: Select your team

---

## Project Configuration

### Info.plist Settings

Add these keys to `Info.plist`:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Zeilumara needs notifications to remind you of scheduled events at the correct human time.</string>

<key>NSCalendarsUsageDescription</key>
<string>Zeilumara can add events to your calendar for better integration.</string>

<key>UILaunchScreen</key>
<dict>
    <key>UIImageName</key>
    <string>LaunchImage</string>
</dict>

<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>
```

### Capabilities

Add these capabilities in Xcode:

1. **Push Notifications** (if adding remote notifications later):
   - Signing & Capabilities → + Capability → Push Notifications

2. **Background Modes** (optional, for future features):
   - Background fetch
   - Remote notifications

### Build Settings

Recommended settings:

- **Swift Language Version**: Swift 5
- **iOS Deployment Target**: 16.0
- **Enable Bitcode**: No
- **Swift Optimization Level**: 
  - Debug: None (-Onone)
  - Release: Optimize for Speed (-O)

---

## Building

### Build from Xcode

1. Select scheme: `Zeilumara Time`
2. Select destination: 
   - Simulator: iPhone 14 Pro or later
   - Device: Your connected iPhone
3. Press `⌘B` (Build) or `⌘R` (Build & Run)

### Build from Command Line

```bash
# Build for simulator
xcodebuild -scheme "Zeilumara Time" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  build

# Build for device
xcodebuild -scheme "Zeilumara Time" \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  build
```

### Clean Build

```bash
# In Xcode: Shift+⌘K
# Command line:
xcodebuild clean
```

---

## Testing

### Running Tests in Xcode

1. **All tests**: `⌘U`
2. **Single test**: Click diamond icon next to test method
3. **Test class**: Click diamond icon next to class name

### Command Line Testing

```bash
# Run all tests
xcodebuild test \
  -scheme "Zeilumara Time" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 14,OS=17.0'

# Run specific test
xcodebuild test \
  -scheme "Zeilumara Time" \
  -only-testing:ZeilumaraTimeTests/TimeConversionTests/testRoundTripConversion
```

### Test Coverage

Enable code coverage:

1. Edit Scheme (⌘<)
2. Test action → Options
3. Check "Gather coverage for all targets"
4. Run tests
5. View coverage: Report Navigator → Coverage tab

Target coverage: **>80%** for Services/

### Writing Tests

Example test structure:

```swift
final class MyFeatureTests: XCTestCase {
    var sut: MyFeature!  // System Under Test
    
    override func setUp() {
        super.setUp()
        sut = MyFeature()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testMyFeature() {
        // Given
        let input = "test"
        
        // When
        let result = sut.process(input)
        
        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

---

## Debugging

### Print Debugging

Add to TimeConversionService for verbose logging:

```swift
#if DEBUG
print("🕐 Converting: \(date) -> \(components)")
#endif
```

### Breakpoints

1. Click line number to add breakpoint
2. Right-click → Edit Breakpoint → Add Action:
   - Log Message: `Date: @date@, Components: @components@`
   - Check "Automatically continue"

### LLDB Commands

```bash
# Print variable
po myVariable

# Print object description
p myVariable

# Continue execution
c

# Step over
n

# Step into
s
```

### View Hierarchy Debugger

Debug view layout issues:

1. Run app in simulator
2. Debug → View Debugging → Capture View Hierarchy
3. Inspect view constraints and frames

### Memory Graph Debugger

Debug memory leaks:

1. Run app
2. Debug → Memory Graph
3. Look for retention cycles

### Notification Debugging

View pending notifications:

```swift
UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
    print("📱 Pending notifications:")
    for request in requests {
        print("  - \(request.identifier): \(request.content.title)")
        if let trigger = request.trigger as? UNCalendarNotificationTrigger {
            print("    Fires at: \(trigger.nextTriggerDate() ?? Date())")
        }
    }
}
```

---

## Deployment

### Device Testing

1. **Connect iPhone via USB**

2. **Trust Computer**:
   - Unlock iPhone
   - Tap "Trust" when prompted

3. **Select Device** in Xcode

4. **Build & Run**: `⌘R`

5. **Trust Developer**:
   - Settings → General → VPN & Device Management
   - Trust your developer certificate

### TestFlight (Beta Testing)

1. **Archive Build**:
   - Product → Archive
   - Wait for archive to complete

2. **Upload to App Store Connect**:
   - Organizer window opens automatically
   - Select archive → Distribute App
   - App Store Connect → Upload
   - Follow prompts

3. **Configure in App Store Connect**:
   - Go to https://appstoreconnect.apple.com
   - My Apps → Zeilumara Time → TestFlight
   - Add build notes
   - Add internal/external testers

4. **Beta Testing**:
   - Internal testing: Available immediately
   - External testing: Requires Apple review (~24 hours)

### App Store Release

1. **Prepare Metadata**:
   - App name, description, keywords
   - Screenshots (required sizes)
   - App icon (1024x1024)
   - Privacy policy URL

2. **Submit for Review**:
   - App Store Connect → My Apps → Zeilumara Time
   - Select build from TestFlight
   - Complete all metadata
   - Submit for Review

3. **Review Time**: Usually 1-3 days

4. **Release Options**:
   - Manual release
   - Automatic after approval
   - Scheduled release date

---

## CI/CD

### GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: macos-13
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Show Xcode version
      run: xcodebuild -version
    
    - name: Build
      run: |
        xcodebuild -scheme "Zeilumara Time" \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,name=iPhone 14,OS=17.0' \
          build
    
    - name: Run Tests
      run: |
        xcodebuild test \
          -scheme "Zeilumara Time" \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,name=iPhone 14,OS=17.0' \
          -enableCodeCoverage YES
    
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage.xml
```

### Fastlane Setup

Install Fastlane:

```bash
brew install fastlane
cd swift_time
fastlane init
```

Create `Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "Zeilumara Time",
      devices: ["iPhone 14"]
    )
  end

  desc "Build app"
  lane :build do
    build_app(
      scheme: "Zeilumara Time",
      export_method: "development"
    )
  end

  desc "Deploy to TestFlight"
  lane :beta do
    build_app(
      scheme: "Zeilumara Time",
      export_method: "app-store"
    )
    upload_to_testflight
  end
end
```

Run lanes:

```bash
fastlane test
fastlane build
fastlane beta
```

---

## Troubleshooting

### Common Issues

#### Build Errors

**Issue**: "No such module 'SwiftUI'"
**Solution**: Ensure iOS Deployment Target is 16.0+

**Issue**: Code signing error
**Solution**: 
- Xcode → Preferences → Accounts → Add Apple ID
- Select project → Signing & Capabilities → Select Team

#### Runtime Issues

**Issue**: Notifications not appearing
**Solution**:
- Check notification permissions in Settings
- Verify notification is scheduled: `getPendingNotificationRequests`
- Test on physical device (simulator has limitations)

**Issue**: Events not persisting
**Solution**:
- Check file permissions
- Verify documentsDirectory is writable
- Check for JSON encoding errors in console

**Issue**: Time conversion inaccurate
**Solution**:
- Verify epoch is correct in settings
- Check ZeilumaraConstants values
- Run unit tests to identify conversion issues

#### Simulator Issues

**Issue**: Simulator slow or unresponsive
**Solution**:
```bash
# Reset simulator
xcrun simctl erase all

# Restart simulator
killall Simulator
```

**Issue**: Notification permission prompt not showing
**Solution**: Reset privacy warnings:
- Simulator → Reset Content and Settings

### Debug Checklist

- [ ] Clean build folder (Shift+⌘K)
- [ ] Restart Xcode
- [ ] Update to latest Xcode
- [ ] Check console for errors
- [ ] Verify Info.plist keys
- [ ] Test on physical device
- [ ] Review recent code changes
- [ ] Check stack trace

### Performance Issues

Use Instruments for profiling:

1. Product → Profile (`⌘I`)
2. Select instrument:
   - Time Profiler: CPU usage
   - Allocations: Memory usage
   - Leaks: Memory leaks
3. Record and analyze

### Getting Help

- **Apple Documentation**: https://developer.apple.com/documentation/
- **Swift Forums**: https://forums.swift.org
- **Stack Overflow**: Tag with `swift`, `swiftui`, `ios`
- **Xcode Issues**: https://developer.apple.com/bug-reporting/

---

## Best Practices

### Code Organization

- Keep views small (<200 lines)
- Extract reusable components
- Separate business logic from UI
- Use SwiftUI ViewModels for complex views

### Performance

- Use `@State` for view-local state
- Use `@ObservedObject` for shared state
- Avoid expensive operations in view body
- Use `@MainActor` for UI updates

### Testing

- Test business logic, not UI
- Mock external dependencies
- Use descriptive test names
- Aim for >80% coverage on Services/

### Version Control

```bash
# Good commit message
git commit -m "feat: Add timezone translation view"
git commit -m "fix: Correct lumibeat calculation in conversion"
git commit -m "test: Add round-trip conversion tests"

# Commit prefixes:
# feat: New feature
# fix: Bug fix
# docs: Documentation
# test: Tests
# refactor: Code refactoring
# style: Formatting
# chore: Maintenance
```

---

## Next Steps

1. **Add Features**: See README.md Roadmap
2. **Improve UI**: Add animations and transitions
3. **Add Widgets**: Lock screen and home screen widgets
4. **Add Watch App**: Companion watchOS app
5. **Add Localization**: Support multiple languages
6. **Add Analytics**: Track usage (privacy-focused)

---

**Happy Coding! 🌌**
