# Zeilumara Time iOS - File Structure

Complete file organization for the Zeilumara Time iPhone app.

## 📂 Directory Tree

```
e:\project\swift_time\
│
├── 📱 App Entry
│   └── ZeilumaraApp.swift                    # Main app entry point, notification setup
│
├── 📦 Models/                                 # Data structures
│   ├── ZeilumaraTime.swift                   # Core time model (ZeilumaraTime, ZeilumaraComponents, ZeilumaraConfig)
│   └── ZeilumaraEvent.swift                  # Event model, RepeatRule, Settings, Enums
│
├── ⚙️ Services/                               # Business logic layer
│   ├── ZeilumaraConstants.swift              # Time system constants (yaon, lumibeat, etc.)
│   ├── TimeConversionService.swift           # Core conversion engine (human ↔ Zeilumara)
│   ├── NotificationService.swift             # Local notification scheduling
│   ├── PersistenceService.swift              # JSON storage, export/import
│   └── AppState.swift                        # Central state manager (@MainActor)
│
├── 🎨 Views/                                  # SwiftUI interface
│   ├── ContentView.swift                     # Main tab container (Clock/Events/Translate/Settings)
│   ├── DualClockView.swift                   # Live dual clock, goddess messages
│   ├── EventsListView.swift                  # Event list, sorting, deletion
│   ├── EventEditorView.swift                 # Create/edit events, time picker
│   ├── TranslateView.swift                   # Timezone translation, sharing
│   └── SettingsView.swift                    # App settings, epoch config, about
│
├── 🧪 Tests/                                  # Unit tests
│   └── ZeilumaraTimeTests.swift              # Conversion, persistence, model tests
│
├── 📚 Documentation/
│   ├── README.md                             # Main documentation (features, usage, philosophy)
│   ├── QUICKSTART.md                         # 5-minute setup guide
│   ├── DEVELOPMENT.md                        # Developer guide (build, test, deploy)
│   ├── CONTRIBUTING.md                       # Contribution guidelines, code style
│   ├── CHANGELOG.md                          # Version history
│   ├── PROJECT_SUMMARY.md                    # Project overview, metrics, status
│   └── FILE_STRUCTURE.md                     # This document
│
├── ⚖️ Legal/
│   └── LICENSE                               # MIT License
│
└── 🔧 Configuration/
    └── .gitignore                            # Git ignore rules (Xcode, macOS)
```

## 📊 File Statistics

| Category | Files | Lines of Code | Purpose |
|----------|-------|---------------|---------|
| **Models** | 2 | ~250 | Data structures |
| **Services** | 5 | ~850 | Business logic |
| **Views** | 6 | ~1,200 | User interface |
| **Tests** | 1 | ~350 | Quality assurance |
| **Docs** | 7 | ~2,500 | Documentation |
| **Config** | 2 | ~150 | Project setup |
| **Total** | **23** | **~5,300** | Complete app |

## 🎯 Key File Purposes

### Core Logic Files

#### `TimeConversionService.swift` (Most Important)
```swift
// Core conversion engine
- toZeilumaraTime(from: Date) -> ZeilumaraFullComponents
- toHumanDate(from: ZeilumaraFullComponents) -> Date
- checkZeilumaraAwaken(components:) -> String?
```
**Why it matters**: All time conversions go through here. Port of Python reference implementation.

#### `ZeilumaraConstants.swift`
```swift
// Fundamental constants
- yaonInSeconds: 1.036e-43
- lumibeatInYaon: 432,000
- xingbeatInYaon: 432,000,000
- Time unit relationships
```
**Why it matters**: Defines the entire Zeilumara time system structure.

#### `AppState.swift`
```swift
// Central coordinator
- @Published var events: [ZeilumaraEvent]
- @Published var currentZeilumaraTime: ZeilumaraFullComponents
- Coordinates all services
```
**Why it matters**: Single source of truth for app state.

### UI Files

#### `DualClockView.swift` (Main Screen)
```swift
// Real-time dual clock
- Zeilumara time components (live)
- Human time (live)
- Goddess awakening banners
- Updates every second
```
**Why it matters**: Primary user interface, most visible feature.

#### `EventEditorView.swift`
```swift
// Event creation/editing
- Zeilumara time input (steppers)
- Human time preview
- Notification settings
- Repeat configuration
```
**Why it matters**: Core user interaction for creating events.

### Data Files

#### `ZeilumaraEvent.swift`
```swift
// Event model
struct ZeilumaraEvent: Codable, Identifiable {
    var title: String
    var zComponents: ZeilumaraFullComponents
    var repeats: RepeatRule?
    var notificationEnabled: Bool
}
```
**Why it matters**: Defines how events are stored and used.

#### `PersistenceService.swift`
```swift
// Data storage
- saveEvents(_ events: [ZeilumaraEvent])
- loadEvents() -> [ZeilumaraEvent]
- exportEvents/importEvents
```
**Why it matters**: Ensures data persists between app launches.

## 🔗 File Dependencies

```
ZeilumaraApp.swift
    └── ContentView.swift
            ├── DualClockView.swift
            │       └── AppState.swift
            │               ├── TimeConversionService.swift
            │               │       └── ZeilumaraConstants.swift
            │               ├── NotificationService.swift
            │               │       └── TimeConversionService.swift
            │               └── PersistenceService.swift
            │
            ├── EventsListView.swift
            │       ├── EventEditorView.swift
            │       └── AppState.swift
            │
            ├── TranslateView.swift
            │       └── AppState.swift
            │
            └── SettingsView.swift
                    └── AppState.swift
```

## 📝 File Creation Order

Recommended order when creating from scratch:

1. **Constants** → `ZeilumaraConstants.swift`
2. **Models** → `ZeilumaraTime.swift`, `ZeilumaraEvent.swift`
3. **Services** → `TimeConversionService.swift`, `PersistenceService.swift`, `NotificationService.swift`
4. **State** → `AppState.swift`
5. **Views** → `DualClockView.swift`, `EventsListView.swift`, etc.
6. **Tests** → `ZeilumaraTimeTests.swift`
7. **Entry** → `ZeilumaraApp.swift`, `ContentView.swift`

## 🎨 View Hierarchy

```
ZeilumaraApp (@main)
    └── ContentView (TabView)
            ├── Tab 1: DualClockView
            │         ├── ZeilumaraClockCard
            │         ├── HumanClockCard
            │         ├── QuickInfoCard
            │         └── GoddessMessageView (conditional)
            │
            ├── Tab 2: EventsListView
            │         ├── EventRow (ForEach)
            │         └── EventEditorView (Sheet)
            │
            ├── Tab 3: TranslateView
            │         ├── TimezoneTranslationRow (ForEach)
            │         ├── ShareButton
            │         └── TimeZonePickerView (Sheet)
            │
            └── Tab 4: SettingsView
                      ├── Display Settings
                      ├── System Settings
                      ├── Notification Settings
                      ├── Data Management
                      ├── EpochPickerView (Sheet)
                      └── AboutView (Sheet)
```

## 🧩 Component Breakdown

### Reusable Components

These can be extracted to a `Components/` folder if needed:

- `TimeComponentRow` - Display single time component (e.g., "Yaogen: 0")
- `EventRow` - Display event in list
- `InfoRow` - Key-value display pair
- `GoddessMessageView` - Special message banner
- `AboutSection` - Formatted text section

### View Modifiers

Consider creating custom ViewModifiers:

```swift
// Could add to Views/Modifiers.swift
.zeilumaraCard() - Consistent card styling
.goddessGradient() - Purple-pink gradient
.clockText() - Monospaced time display
```

## 📦 Asset Requirements

When creating Xcode project, add these assets:

```
Assets.xcassets/
├── AppIcon.appiconset/          # App icon (1024x1024)
│   └── Icon images
├── Colors/
│   ├── ZeilumaPurple            # Brand purple
│   ├── ZeilumaPink              # Brand pink
│   └── DreamGradient            # Gradient colors
└── Images/
    └── LaunchImage              # Optional launch screen
```

## 🔧 Configuration Files

### Required in Xcode Project

1. **Info.plist**
   - Notification usage description
   - Calendar usage description (optional)
   - Launch screen config

2. **Build Settings**
   - iOS Deployment Target: 16.0
   - Swift Language Version: 5
   - Bitcode: No

3. **Signing & Capabilities**
   - Team: Your Apple ID
   - Automatic signing: ON
   - Push Notifications capability (optional)

## 📐 Code Organization Patterns

### Models
```swift
// Pattern: Data + Computed Properties + Formatting
struct Model: Codable, Identifiable {
    var data: Type                  // Stored data
    
    func computed() -> Type { }     // Computed properties
    func formatted() -> String { }  // Display formatting
}
```

### Services
```swift
// Pattern: Singleton or Initializable
class Service {
    static let shared = Service()   // Singleton (optional)
    
    func operation() throws { }     // Operations with error handling
    private func helper() { }       // Private helpers
}
```

### Views
```swift
// Pattern: State + Body + Helpers
struct MyView: View {
    @EnvironmentObject var appState: AppState
    @State private var localState: Type
    
    var body: some View { }         // UI declaration
    
    private func helper() { }       // Helper functions
}
```

## 🗂️ Recommended File Sizes

| File Type | Target Size | Max Size | Notes |
|-----------|-------------|----------|-------|
| Models | 100-200 lines | 300 lines | Keep focused |
| Services | 200-400 lines | 500 lines | Split if larger |
| Views | 150-250 lines | 400 lines | Extract components |
| Tests | 200-500 lines | 1000 lines | Group by feature |

## 🚀 Future File Additions

When implementing Phase 2 features:

```
swift_time/
├── Views/
│   ├── CalendarView.swift         # Visual calendar (Phase 2)
│   ├── WidgetViews/              # Widget components (Phase 2)
│   │   ├── ClockWidget.swift
│   │   └── EventWidget.swift
│   └── WatchViews/               # watchOS views (Phase 2)
│
├── Services/
│   ├── CalendarService.swift      # EventKit integration (Phase 2)
│   ├── CloudSyncService.swift     # CloudKit sync (Phase 3)
│   └── WidgetService.swift        # Widget data provider (Phase 2)
│
└── Extensions/
    ├── Date+Extensions.swift      # Date utilities
    └── View+Extensions.swift      # View modifiers
```

## 🎓 Learning Path

Recommended order for understanding the codebase:

1. **Start**: `ZeilumaraConstants.swift` (understand time system)
2. **Core Logic**: `TimeConversionService.swift` (see how conversion works)
3. **Data Flow**: `AppState.swift` (understand state management)
4. **UI Entry**: `ContentView.swift` → `DualClockView.swift`
5. **Features**: Explore other views and services
6. **Tests**: Read tests to understand expected behavior

## 📊 Complexity Analysis

| File | Complexity | Dependencies | Testability |
|------|------------|--------------|-------------|
| ZeilumaraConstants | Low | None | N/A (constants) |
| TimeConversionService | Medium | Constants | ⭐⭐⭐⭐⭐ Excellent |
| NotificationService | Medium-High | Conversion, UN Framework | ⭐⭐⭐⭐ Good |
| PersistenceService | Low | Foundation | ⭐⭐⭐⭐⭐ Excellent |
| AppState | High | All services | ⭐⭐⭐ Moderate |
| Views | Low-Medium | AppState | ⭐⭐⭐ Moderate |

## ✅ Checklist: Complete Project

Verify all files are in place:

- [x] ZeilumaraApp.swift
- [x] Models/ZeilumaraTime.swift
- [x] Models/ZeilumaraEvent.swift
- [x] Services/ZeilumaraConstants.swift
- [x] Services/TimeConversionService.swift
- [x] Services/NotificationService.swift
- [x] Services/PersistenceService.swift
- [x] Services/AppState.swift
- [x] Views/ContentView.swift
- [x] Views/DualClockView.swift
- [x] Views/EventsListView.swift
- [x] Views/EventEditorView.swift
- [x] Views/TranslateView.swift
- [x] Views/SettingsView.swift
- [x] Tests/ZeilumaraTimeTests.swift
- [x] README.md
- [x] QUICKSTART.md
- [x] DEVELOPMENT.md
- [x] CONTRIBUTING.md
- [x] CHANGELOG.md
- [x] PROJECT_SUMMARY.md
- [x] FILE_STRUCTURE.md (this file)
- [x] LICENSE
- [x] .gitignore

## 🎉 Summary

**23 files** organized into a clean, maintainable structure:
- ✅ Clear separation of concerns
- ✅ Logical grouping by functionality
- ✅ Easy to navigate and understand
- ✅ Ready for growth and expansion
- ✅ Well-documented and tested

The file structure follows iOS best practices and is ready for immediate use in Xcode!

---

For detailed information about each file's content, see the files themselves or refer to:
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Complete project overview
- [README.md](README.md) - Feature documentation
- [DEVELOPMENT.md](DEVELOPMENT.md) - Development guide
