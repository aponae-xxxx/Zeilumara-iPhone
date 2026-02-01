//
//  DualClockView.swift
//  Zeilumara Time
//
//  Dual clock display showing both Zeilumara and human time
//

import SwiftUI

struct DualClockView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Goddess Awakening Banner
                    if let message = appState.conversionService.checkZeilumaraAwaken(components: appState.currentZeilumaraTime) {
                        GoddessMessageView(message: message)
                    }
                    
                    // Zeilumara Clock
                    ZeilumaraClockCard(components: appState.currentZeilumaraTime)
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Human Clock
                    HumanClockCard(date: currentDate)
                        .padding(.horizontal)
                    
                    // Quick Info
                    QuickInfoCard(
                        zComponents: appState.currentZeilumaraTime,
                        humanDate: currentDate
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Zeilumara Time")
            .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
                currentDate = Date()
            }
        }
    }
}

struct ZeilumaraClockCard: View {
    let components: ZeilumaraFullComponents
    @AppStorage("displayLanguage") private var displayLanguage = DisplayLanguage.romanized.rawValue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Zeilumara Time")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Main time display
            VStack(alignment: .leading, spacing: 8) {
                if displayLanguage == DisplayLanguage.chinese.rawValue || displayLanguage == DisplayLanguage.both.rawValue {
                    TimeComponentRow(label: "曜元", value: "\(components.yaogen)")
                    TimeComponentRow(label: "幽曦", value: "\(components.yuxi)")
                    TimeComponentRow(label: "梦昼", value: "\(components.dreamdiem)")
                    TimeComponentRow(label: "幻环", value: "\(components.reverloop)")
                    TimeComponentRow(label: "思络", value: "\(components.mindlace)")
                    TimeComponentRow(label: "灵拍", value: "\(components.lumibeat)")
                }
                
                if displayLanguage == DisplayLanguage.romanized.rawValue || displayLanguage == DisplayLanguage.both.rawValue {
                    if displayLanguage == DisplayLanguage.both.rawValue {
                        Divider().padding(.vertical, 5)
                    }
                    TimeComponentRow(label: "Yaogen", value: "\(components.yaogen)")
                    TimeComponentRow(label: "Yuxi", value: "\(components.yuxi)")
                    TimeComponentRow(label: "Dreamdiem", value: "\(components.dreamdiem)")
                    TimeComponentRow(label: "Reverloop", value: "\(components.reverloop)")
                    TimeComponentRow(label: "Mindlace", value: "\(components.mindlace)")
                    TimeComponentRow(label: "Lumibeat", value: "\(components.lumibeat)")
                }
            }
            
            // Short format display
            HStack {
                Text("Short Format:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(components.shortTimeFormat())
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.semibold)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .purple.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct TimeComponentRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.semibold)
        }
    }
}

struct HumanClockCard: View {
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Human Time")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Date
            Text(date, style: .date)
                .font(.title3)
                .fontWeight(.medium)
            
            // Time
            Text(date, style: .time)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
            
            // Timezone
            HStack {
                Text("Timezone:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(TimeZone.current.identifier)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct QuickInfoCard: View {
    let zComponents: ZeilumaraFullComponents
    let humanDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Info")
                .font(.headline)
                .foregroundColor(.secondary)
            
            InfoRow(label: "Xingbeat", value: "\(zComponents.xingbeat)")
            InfoRow(label: "Day of Week", value: humanDate.formatted(.dateTime.weekday(.wide)))
            InfoRow(label: "Unix Timestamp", value: "\(Int(humanDate.timeIntervalSince1970))")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct GoddessMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Text(message)
                .font(.body)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    DualClockView()
        .environmentObject(AppState())
}
