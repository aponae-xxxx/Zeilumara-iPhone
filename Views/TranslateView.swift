//
//  TranslateView.swift
//  Zeilumara Time
//
//  Translate between Zeilumara and multiple human timezones
//

import SwiftUI

struct TranslateView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimezones: [TimeZone] = [
        TimeZone.current,
        TimeZone(identifier: "America/New_York")!,
        TimeZone(identifier: "Europe/London")!,
        TimeZone(identifier: "Asia/Tokyo")!
    ]
    @State private var showingTimezonePicker = false
    @State private var inputYaogen: Int = 0
    @State private var inputYuxi: Int = 0
    @State private var inputDreamdiem: Int = 0
    @State private var inputReverloop: Int = 0
    @State private var inputMindlace: Int = 0
    @State private var inputLumibeat: Int = 0
    @State private var useCurrentTime: Bool = true
    
    var inputComponents: ZeilumaraFullComponents {
        if useCurrentTime {
            return appState.currentZeilumaraTime
        } else {
            return ZeilumaraFullComponents(
                yaogen: inputYaogen,
                yuxi: inputYuxi,
                dreamdiem: inputDreamdiem,
                reverloop: inputReverloop,
                mindlace: inputMindlace,
                lumibeat: inputLumibeat,
                yaon: 0,
                xingbeat: 0
            )
        }
    }
    
    var humanDate: Date {
        appState.conversionService.toHumanDate(from: inputComponents)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Zeilumara Time") {
                    Toggle("Use Current Time", isOn: $useCurrentTime)
                    
                    if !useCurrentTime {
                        Stepper("Yaogen: \(inputYaogen)", value: $inputYaogen, in: 0...100)
                        Stepper("Yuxi: \(inputYuxi)", value: $inputYuxi, in: 0...359)
                        Stepper("Dreamdiem: \(inputDreamdiem)", value: $inputDreamdiem, in: 0...6)
                        Stepper("Reverloop: \(inputReverloop)", value: $inputReverloop, in: 0...8)
                        Stepper("Mindlace: \(inputMindlace)", value: $inputMindlace, in: 0...5)
                        Stepper("Lumibeat: \(inputLumibeat)", value: $inputLumibeat, in: 0...63)
                    } else {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(inputComponents.formattedRoman())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Translations") {
                    ForEach(selectedTimezones, id: \.identifier) { timezone in
                        TimezoneTranslationRow(
                            timezone: timezone,
                            date: humanDate
                        )
                    }
                    .onDelete { offsets in
                        selectedTimezones.remove(atOffsets: offsets)
                    }
                    
                    Button {
                        showingTimezonePicker = true
                    } label: {
                        Label("Add Timezone", systemImage: "plus.circle")
                    }
                }
                
                Section("Share") {
                    ShareButton(
                        zComponents: inputComponents,
                        timezones: selectedTimezones,
                        conversionService: appState.conversionService
                    )
                }
            }
            .navigationTitle("Translate")
            .sheet(isPresented: $showingTimezonePicker) {
                TimeZonePickerView(selectedTimezones: $selectedTimezones)
            }
        }
    }
}

struct TimezoneTranslationRow: View {
    let timezone: TimeZone
    let date: Date
    
    var localDate: Date {
        // Convert to the target timezone
        return date
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(timezone.identifier)
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(formattedDate)
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(formattedTime)
                    .font(.subheadline)
            }
            
            if let offset = timezone.secondsFromGMT(for: date) as Int? {
                let hours = offset / 3600
                let sign = hours >= 0 ? "+" : ""
                Text("UTC\(sign)\(hours)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ShareButton: View {
    let zComponents: ZeilumaraFullComponents
    let timezones: [TimeZone]
    let conversionService: TimeConversionService
    
    var shareText: String {
        let humanDate = conversionService.toHumanDate(from: zComponents)
        
        var text = "🌌 Zeilumara Time Translation\n\n"
        text += "Zeilumara Time:\n"
        text += zComponents.formattedRoman()
        text += "\n\nHuman Time Translations:\n"
        
        for timezone in timezones {
            let formatter = DateFormatter()
            formatter.timeZone = timezone
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            
            text += "\n\(timezone.identifier):\n"
            text += formatter.string(from: humanDate)
        }
        
        return text
    }
    
    var body: some View {
        ShareLink(item: shareText) {
            Label("Share Translations", systemImage: "square.and.arrow.up")
        }
    }
}

struct TimeZonePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTimezones: [TimeZone]
    @State private var searchText = ""
    
    let allTimezones = TimeZone.knownTimeZoneIdentifiers.compactMap { TimeZone(identifier: $0) }
    
    var filteredTimezones: [TimeZone] {
        if searchText.isEmpty {
            return allTimezones
        } else {
            return allTimezones.filter { timezone in
                timezone.identifier.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTimezones, id: \.identifier) { timezone in
                    Button {
                        if !selectedTimezones.contains(where: { $0.identifier == timezone.identifier }) {
                            selectedTimezones.append(timezone)
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Text(timezone.identifier)
                            Spacer()
                            if selectedTimezones.contains(where: { $0.identifier == timezone.identifier }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search timezones")
            .navigationTitle("Add Timezone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TranslateView()
        .environmentObject(AppState())
}
