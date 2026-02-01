//
//  ContentView.swift
//  Zeilumara Time
//
//  Main tabbed interface for the app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            DualClockView()
                .tabItem {
                    Label("Clock", systemImage: "clock.fill")
                }
            
            EventsListView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            TranslateView()
                .tabItem {
                    Label("Translate", systemImage: "globe")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
