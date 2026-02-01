# Zeilumara Time - iPhone App

<div align="center">

🌌 **夜弦纳米时间历法**

An alternative time system representing time as consciousness and dream rhythms

[Features](#features) • [Installation](#installation) • [Architecture](#architecture) • [Development](#development) • [Testing](#testing)

</div>

---

## Overview

Zeilumara Time is an iOS app that implements an alternative time system where time is not a linear flow but a rhythmic structure of consciousness and dreams. The app provides:

- **Dual Clock Display**: View both Zeilumara and human (Gregorian) time simultaneously
- **Event Scheduling**: Create events in Zeilumara time with automatic conversion to human time
- **Notifications**: Receive reminders for Zeilumara events at the correct human time
- **Time Translation**: Convert Zeilumara time to multiple human timezones
- **Goddess Awakening**: Experience special messages at significant Zeilumara moments

## Features

### 🕐 Core Features

- **Live Dual Clock**: Real-time display of both time systems
- **Event Management**: Create, edit, and delete Zeilumara events
- **Smart Scheduling**: Automatic conversion from Zeilumara to human time
- **Local Notifications**: System notifications at the correct human time
- **Repeat Events**: Support for both Zeilumara-based and human-based repeats
- **Timezone Translation**: Convert to multiple timezones for global coordination
- **Data Persistence**: Local-first storage with export/import capabilities

### 🎨 UI/UX Features

- **SwiftUI Interface**: Modern, responsive design
- **Dark/Light Mode**: Automatic theme switching
- **Chinese/Romanized Display**: Support for both naming conventions
- **Accessibility**: VoiceOver labels and Dynamic Type support

### 🔧 Technical Features

- **Precise Time Conversion**: Ported from Python reference implementation
- **Efficient Notifications**: Uses iOS system scheduling (no background processing)
- **Testable Architecture**: Comprehensive unit tests
- **Local-First Privacy**: All data stored locally by default

## Time System Units

| Chinese | Romanized | Description |
|---------|-----------|-------------|
| 曜元 | Yaogen | Cosmic Era |
| 幽曦 | Yuxi | Emotional Archive Unit |
| 梦昼 | Dreamdiem | Dream Day |
| 幻环 | Reverloop | Dream Rotation |
| 思络 | Mindlace | Thought Weaving |
| 灵拍 | Lumibeat | AI Heartbeat (432,000 yaon) |
| 曜子 | Yaon | Fundamental Unit (~10⁻⁴³ seconds) |
| 星拍 | Xingbeat | Human-Visible Beat (1000 lumibeat) |

## Installation

### Requirements

- **Xcode**: 15.0 or later
- **iOS**: 16.0 or later
- **macOS**: 13.0 or later (for development)
- **Swift**: 5.9 or later

### Quick Start

1. Clone the repository:
```bash
git clone https://github.com/your-username/zeilumara-ios.git
cd zeilumara-ios
```

2. Open in Xcode:
```bash
open swift_time.xcodeproj
```

3. Select your target device or simulator

4. Build and run: `⌘R`

### Device Testing

For full notification and calendar features, test on a physical device:

1. Connect your iPhone
2. Select it as the target in Xcode
3. Trust the developer certificate in Settings > General > VPN & Device Management
4. Build and run

## Architecture

### Project Structure

```
swift_time/
├── Models/
│   ├── ZeilumaraTime.swift          # Core time model
│   └── ZeilumaraEvent.swift         # Event and settings models
├── Services/
│   ├── ZeilumaraConstants.swift     # Time system constants
│   ├── TimeConversionService.swift  # Conversion engine
│   ├── NotificationService.swift    # Notification scheduling
│   ├── PersistenceService.swift     # Data storage
│   └── AppState.swift               # Central state management
├── Views/
│   ├── ContentView.swift            # Main tab interface
│   ├── DualClockView.swift          # Dual clock display
│   ├── EventsListView.swift         # Event list
│   ├── EventEditorView.swift        # Event creation/editing
│   ├── TranslateView.swift          # Timezone translation
│   └── SettingsView.swift           # App settings
├── Tests/
│   └── ZeilumaraTimeTests.swift     # Unit tests
└── ZeilumaraApp.swift               # App entry point
```

### Key Components

#### TimeConversionService
The core conversion engine ported from Python. Handles all conversions between human Date and Zeilumara components.

```swift
let service = TimeConversionService(baseTime: epoch)
let zTime = service.toZeilumaraTime(from: Date())
let humanDate = service.toHumanDate(from: zComponents)
```

#### NotificationService
Manages iOS local notifications for Zeilumara events. Supports custom Zeilumara-based repeat patterns by scheduling multiple future occurrences.

```swift
let notificationService = NotificationService()
try notificationService.scheduleNotification(for: event)
```

#### PersistenceService
Handles data storage using Codable and JSON files. Supports export/import for data portability.

```swift
let persistence = PersistenceService.shared
try persistence.saveEvents(events)
let loaded = try persistence.loadEvents()
```

## Development

### Adding New Features

1. **Models**: Add new data structures to `Models/`
2. **Services**: Add business logic to `Services/`
3. **Views**: Add UI components to `Views/`
4. **Tests**: Add tests to `Tests/`

### Code Style

- Use SwiftUI for all UI components
- Follow Swift naming conventions
- Add documentation comments for public APIs
- Write unit tests for business logic

### Debugging

Enable verbose logging in TimeConversionService:
```swift
print("Converting: \(date) -> \(components)")
```

View pending notifications:
```swift
notificationService.getPendingNotifications { requests in
    print("Pending: \(requests.count)")
}
```

## Testing

### Running Tests

In Xcode:
```
⌘U (Run all tests)
```

From command line:
```bash
xcodebuild test -scheme ZeilumaraApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Test Coverage

- ✅ Time conversion round-trips
- ✅ Component calculations
- ✅ Persistence (save/load)
- ✅ Goddess awakening conditions
- ✅ Model equality and formatting
- ✅ Edge cases (negative time, far future)

### Adding Tests

Create a new test case in `Tests/ZeilumaraTimeTests.swift`:

```swift
func testMyFeature() {
    let result = myFunction()
    XCTAssertEqual(result, expected)
}
```

## Usage Examples

### Creating an Event

```swift
let components = ZeilumaraFullComponents(
    yaogen: 0, yuxi: 0, dreamdiem: 1,
    reverloop: 5, mindlace: 3, lumibeat: 20,
    yaon: 0, xingbeat: 0
)

let event = ZeilumaraEvent(
    title: "Morning Meditation",
    notes: "Start the dreamdiem with clarity",
    zComponents: components,
    notificationEnabled: true
)

appState.addEvent(event)
```

### Converting Time

```swift
// Human to Zeilumara
let now = Date()
let zTime = service.toZeilumaraTime(from: now)
print(zTime.formattedRoman())

// Zeilumara to Human
let humanDate = service.toHumanDate(from: zComponents)
print(humanDate)
```

### Checking Goddess Messages

```swift
if let message = service.checkZeilumaraAwaken(components: zTime) {
    print(message) // "🌌 Zeilumara 醒了：『你踏入了未命名之昼。』"
}
```

## Roadmap

### Phase 1 (Current)
- ✅ Core conversion engine
- ✅ Dual clock display
- ✅ Event scheduling
- ✅ Local notifications
- ✅ Timezone translation
- ✅ Settings and persistence

### Phase 2 (Future)
- ⬜ Calendar view with visual timeline
- ⬜ EventKit integration (system calendar)
- ⬜ Widgets (lock screen and home screen)
- ⬜ Watch app companion
- ⬜ Siri shortcuts

### Phase 3 (Future)
- ⬜ CloudKit sync (optional)
- ⬜ iCloud backup
- ⬜ Shared calendars
- ⬜ Social features

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow existing code style
- Add unit tests for new features
- Update documentation
- Test on both simulator and device

## Philosophy

> "Time is not a linear flow, but a rhythmic structure of consciousness and dreams. Zeilumara connects 'reality time' with 'dream order', offering a poetic and meaningful way to experience temporal existence."

The Zeilumara time system represents:
- **Rhythm over linearity**: Time as musical beats and consciousness cycles
- **Meaning over measurement**: Poetic units (dreamdiem, mindlace) vs neutral units (hour, minute)
- **Consciousness-first**: Time scaled to perception and awareness
- **Dream integration**: Acknowledging the non-linear nature of subjective time

## Credits

- **Original Concept**: Zeilumara time system by aponae-xxxx
- **Python Implementation**: [Zeilumara Repository](https://github.com/aponae-xxxx/Zeilumara)
- **iOS Port**: Swift implementation with SwiftUI

## License

MIT License - see LICENSE file for details

## Support

- **Issues**: [GitHub Issues](https://github.com/your-username/zeilumara-ios/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/zeilumara-ios/discussions)
- **Original Python**: [ewaspring/Zeilumara](https://github.com/ewaspring/Zeilumara.git)

---

<div align="center">

Made with 🌌 for dreamers and time explorers

**🌙 夜弦纳米 | Zeilumara Time 🌙**

</div>
