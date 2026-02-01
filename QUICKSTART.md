# Zeilumara Time - Quick Start Guide

This guide will get you up and running with the Zeilumara Time iOS app in minutes.

## Prerequisites Checklist

- [ ] macOS 13.0 or later
- [ ] Xcode 15.0 or later installed
- [ ] Apple ID (free) for device testing
- [ ] iPhone with iOS 16.0+ (optional, for full testing)

## 5-Minute Setup

### Step 1: Create Xcode Project (2 minutes)

1. Open Xcode
2. File → New → Project
3. Choose "App" template (iOS)
4. Configure project:
   - **Product Name**: `Zeilumara Time`
   - **Team**: Your Apple ID
   - **Organization Identifier**: `com.yourname` (or any unique identifier)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
   - **Include Tests**: Yes

5. Save to: `e:\project\swift_time`

### Step 2: Add Source Files (1 minute)

The source files are already in place:

```
e:\project\swift_time\
├── Models/
│   ├── ZeilumaraTime.swift
│   └── ZeilumaraEvent.swift
├── Services/
│   ├── ZeilumaraConstants.swift
│   ├── TimeConversionService.swift
│   ├── NotificationService.swift
│   ├── PersistenceService.swift
│   └── AppState.swift
├── Views/
│   ├── ContentView.swift
│   ├── DualClockView.swift
│   ├── EventsListView.swift
│   ├── EventEditorView.swift
│   ├── TranslateView.swift
│   └── SettingsView.swift
├── Tests/
│   └── ZeilumaraTimeTests.swift
└── ZeilumaraApp.swift
```

**In Xcode Navigator:**
1. Right-click on project
2. Add Files to "Zeilumara Time"...
3. Select all folders (Models, Services, Views, Tests)
4. Check "Copy items if needed"
5. Click "Add"

### Step 3: Configure Info.plist (1 minute)

1. Select project in navigator
2. Select target "Zeilumara Time"
3. Go to "Info" tab
4. Add these keys (click + button):

| Key | Type | Value |
|-----|------|-------|
| `NSUserNotificationsUsageDescription` | String | `Zeilumara needs notifications to remind you of scheduled events.` |
| `NSCalendarsUsageDescription` | String | `Zeilumara can add events to your calendar.` |

### Step 4: Build & Run (1 minute)

1. Select target device: iPhone 14 (simulator)
2. Press `⌘R` or click ▶️ Play button
3. App should launch in simulator!

## First Launch Checklist

When the app launches:

- [ ] Dual clock view appears showing current time
- [ ] Both Zeilumara and human time display
- [ ] Tabs at bottom: Clock, Events, Translate, Settings
- [ ] Notification permission dialog appears

## Testing Core Features

### Test 1: View Current Time (30 seconds)
1. ✅ Clock tab shows live Zeilumara time
2. ✅ Components update every second
3. ✅ Human time displays correctly

### Test 2: Create an Event (1 minute)
1. Go to Events tab
2. Tap + button
3. Fill in:
   - Title: "Test Event"
   - Use current time or adjust values
4. Tap "Create"
5. ✅ Event appears in list
6. ✅ Human date is shown below Zeilumara time

### Test 3: Notifications (1 minute)
1. Grant notification permission if prompted
2. Create an event 2 minutes in the future
3. Enable notification toggle
4. Wait 2 minutes
5. ✅ Notification appears at scheduled time

### Test 4: Time Translation (30 seconds)
1. Go to Translate tab
2. "Use Current Time" toggle ON
3. ✅ Current time converted to multiple timezones
4. Tap "Add Timezone" to add more
5. ✅ Share button creates shareable text

### Test 5: Settings (30 seconds)
1. Go to Settings tab
2. Change display language
3. ✅ Clock updates to show Chinese/Romanized names
4. Try different themes
5. ✅ Theme changes apply

## Troubleshooting First Run

### Issue: "Cannot find type 'UNUserNotificationCenter'"
**Fix**: Add `import UserNotifications` to ZeilumaraApp.swift (already included)

### Issue: Build fails with missing files
**Fix**: 
1. Verify all files are in Xcode navigator (left sidebar)
2. Check "Target Membership" in file inspector (right sidebar)
3. Ensure all .swift files are checked for target "Zeilumara Time"

### Issue: App crashes on launch
**Fix**:
1. Check console for error messages
2. Verify Info.plist keys are added
3. Clean build folder: Shift+⌘K, then ⌘B

### Issue: Simulator slow
**Fix**:
```bash
# Reset simulator
xcrun simctl erase all

# Restart Xcode
killall Xcode
```

## Running Tests

Verify everything works:

```bash
# Press ⌘U in Xcode
# Or from terminal:
xcodebuild test -scheme "Zeilumara Time" \
  -destination 'platform=iOS Simulator,name=iPhone 14'
```

Expected results:
- ✅ All tests pass (green checkmarks)
- ✅ No failures or crashes
- ✅ Test coverage >80% for Services/

## Next Steps

Now that the app is running:

1. **Read the Documentation**:
   - [README.md](README.md) - Project overview
   - [DEVELOPMENT.md](DEVELOPMENT.md) - Development guide
   - [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

2. **Explore the Code**:
   - Start with `TimeConversionService.swift` - Core logic
   - Check out `DualClockView.swift` - Main UI
   - Review `ZeilumaraTimeTests.swift` - Test examples

3. **Test on Device**:
   - Connect your iPhone
   - Select it as target in Xcode
   - Build & run (⌘R)
   - Trust developer certificate in Settings

4. **Customize**:
   - Change colors in views
   - Adjust time components
   - Add new features
   - See CONTRIBUTING.md for guidelines

## Common Questions

**Q: Where is data stored?**
A: App Documents directory. View location:
```swift
print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
```

**Q: How to change the epoch?**
A: Settings tab → "Change Epoch" → Select new date

**Q: How to reset all data?**
A: Settings tab → "Delete All Events"

**Q: Where are notifications scheduled?**
A: System manages them. View pending:
```swift
UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
    print(requests)
}
```

**Q: How accurate is the time conversion?**
A: Within 1 second due to component truncation. See tests for verification.

## Support

Need help?

- 📖 **Documentation**: Check README.md and DEVELOPMENT.md
- 🐛 **Found a bug?**: Open an issue on GitHub
- 💡 **Feature idea?**: Open a discussion on GitHub
- ❓ **Questions?**: Check CONTRIBUTING.md

## Development Workflow

Typical development cycle:

```bash
# 1. Make changes
# Edit .swift files in Xcode

# 2. Run tests
⌘U

# 3. Build & run
⌘R

# 4. Commit
git add .
git commit -m "feat: Add new feature"

# 5. Push
git push origin feature/your-feature
```

## Performance Tips

For best performance:

- 🔋 **Battery**: App uses minimal battery (system handles scheduling)
- 🚀 **Speed**: SwiftUI views are lazy-loaded
- 💾 **Memory**: Data cached in AppState, persisted on changes
- 📱 **Storage**: Events stored as JSON (~1KB per event)

## Deployment Checklist

Ready to test on device or share?

- [ ] All tests pass (⌘U)
- [ ] No warnings in build log
- [ ] Tested on simulator
- [ ] Tested on physical device
- [ ] Notifications work correctly
- [ ] Events persist after app restart
- [ ] Export/import works
- [ ] Settings save correctly

## Success!

You now have a working Zeilumara Time app! 🎉

The app can:
- ✅ Display dual clock (Zeilumara + Human)
- ✅ Create and schedule events
- ✅ Send notifications at correct times
- ✅ Translate between timezones
- ✅ Persist data locally
- ✅ Export/import events

Start exploring and building! 🌌

---

**Happy Coding!**

For detailed information, see:
- [README.md](README.md) - Full documentation
- [DEVELOPMENT.md](DEVELOPMENT.md) - Developer guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
