//
//  EventsListView.swift
//  Zeilumara Time
//
//  List and calendar view of scheduled events
//

import SwiftUI

struct EventsListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddEvent = false
    @State private var selectedEvent: ZeilumaraEvent?
    @State private var sortOption: EventSortOption = .chronological
    
    var sortedEvents: [ZeilumaraEvent] {
        switch sortOption {
        case .chronological:
            return appState.events.sorted { event1, event2 in
                event1.humanDate(using: appState.conversionService) <
                event2.humanDate(using: appState.conversionService)
            }
        case .reverseChronological:
            return appState.events.sorted { event1, event2 in
                event1.humanDate(using: appState.conversionService) >
                event2.humanDate(using: appState.conversionService)
            }
        case .title:
            return appState.events.sorted { $0.title < $1.title }
        }
    }
    
    var upcomingEvents: [ZeilumaraEvent] {
        sortedEvents.filter { !$0.isPast(using: appState.conversionService) }
    }
    
    var pastEvents: [ZeilumaraEvent] {
        sortedEvents.filter { $0.isPast(using: appState.conversionService) }
    }
    
    var body: some View {
        NavigationView {
            List {
                if !upcomingEvents.isEmpty {
                    Section("Upcoming Events") {
                        ForEach(upcomingEvents) { event in
                            EventRow(event: event)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                        .onDelete { offsets in
                            deleteUpcomingEvents(at: offsets)
                        }
                    }
                }
                
                if !pastEvents.isEmpty {
                    Section("Past Events") {
                        ForEach(pastEvents) { event in
                            EventRow(event: event)
                                .opacity(0.6)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                        .onDelete { offsets in
                            deletePastEvents(at: offsets)
                        }
                    }
                }
                
                if appState.events.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Events Yet")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("Tap + to create your first Zeilumara event")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(EventSortOption.allCases) { option in
                                Label(option.displayName, systemImage: option.icon)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Label("Add Event", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                EventEditorView(mode: .create)
            }
            .sheet(item: $selectedEvent) { event in
                EventEditorView(mode: .edit(event))
            }
        }
    }
    
    private func deleteUpcomingEvents(at offsets: IndexSet) {
        for index in offsets {
            appState.deleteEvent(upcomingEvents[index])
        }
    }
    
    private func deletePastEvents(at offsets: IndexSet) {
        for index in offsets {
            appState.deleteEvent(pastEvents[index])
        }
    }
}

struct EventRow: View {
    let event: ZeilumaraEvent
    @EnvironmentObject var appState: AppState
    
    var humanDate: Date {
        event.humanDate(using: appState.conversionService)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                
                Spacer()
                
                if event.repeats != nil {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if event.notificationEnabled {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // Zeilumara time
            Text("Z: \(event.zComponents.compactFormat())")
                .font(.caption)
                .foregroundColor(.purple)
            
            // Human time
            HStack {
                Text(humanDate, style: .date)
                Text("at")
                Text(humanDate, style: .time)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

enum EventSortOption: String, CaseIterable, Identifiable {
    case chronological = "Chronological"
    case reverseChronological = "Reverse Chronological"
    case title = "Title"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .chronological: return "arrow.up"
        case .reverseChronological: return "arrow.down"
        case .title: return "textformat"
        }
    }
}

#Preview {
    EventsListView()
        .environmentObject(AppState())
}
