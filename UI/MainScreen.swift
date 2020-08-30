//
//  MainScreen.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import SwiftUI
import EventKit

struct MainScreen: View {
    @State private var events = [EKEvent]()
    @State private var showingNotOrganizedTasksView = false
    @State private var showingDidNotFindValidMarkdownActionSheet = false
    @State private var buttonsDisabled = false
    @State private var showingExportSuccessfulActionSheet = false
    @State private var showingNotScheduledEventsView = false
    @State private var showingNotParsableLinesView = false
    @State private var manager = ModalSheetViewDataManager()
    
    @State private var beginning = Date(timeIntervalSinceNow: 0)
    @State private var end = Date(timeIntervalSinceNow: 15 * 60)
    
    let store = EKEventStore()
    var calendar: EKCalendar?
    
    init() {
        checkForCalendar(with: store) { calendar in
            self.calendar = calendar
        }
        checkAuthStatus(with: store)
    }
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Beginning", selection: $beginning, displayedComponents: [.hourAndMinute])
                DatePicker("End", selection: $end, displayedComponents: [.hourAndMinute])
                List {
                    Button(action: {
                        copyFromPasteboard()
                    }) {
                        Text("Paste from clipboard/pasteboard")
                            .foregroundColor(buttonsDisabled ? .gray : .blue)
                    }
                    .disabled(buttonsDisabled)
                    .sheet(isPresented: $showingNotParsableLinesView) {
                        NotParsableLinesView(manager: manager)
                    }
                    ForEach(events) { event in
                        EventView(event: event)
                    }
                    Button(action: {
                        exportToCalendar(events: events, delegate: self)
                    }) {
                        Text("Export to Calendar")
                            .foregroundColor(buttonsDisabled ? .gray : .blue)
                    }
                    .disabled(buttonsDisabled)
                    .actionSheet(isPresented: $showingExportSuccessfulActionSheet) {
                        ActionSheet(title: Text("Export successful"), message: Text("Exported tasks to calendar."), buttons: [.default(Text("OK"))])
                    }
                    .sheet(isPresented: $showingNotScheduledEventsView) {
                        NotScheduledEventsView(manager: manager)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing: NavigationLink("Settings", destination: SettingsView()))
            .navigationTitle("Organizer")
            .actionSheet(isPresented: $showingDidNotFindValidMarkdownActionSheet) {
                ActionSheet(title: Text("No data found"), message: Text("Unable to find valid markdown from Things."), buttons: [.default(Text("OK"))])
            }
            .sheet(isPresented: $showingNotOrganizedTasksView) {
                NotOrganizedTasksView(tasks: manager.notOrganizedTasks)
            }
        }
    }
    
    func copyFromPasteboard() {
        let b = Calendar.current.dateComponents([.hour, .minute], from: beginning)
        let e = Calendar.current.dateComponents([.hour, .minute], from: end)
        copyFromPasteboardAndOrganizeTasks(delegate: self, beginComponents: b, endComponents: e)
    }
}

extension MainScreen: CopyFromPasteboardAndOrganizeTasksDelegate {
    func beginOrganizing() {
        buttonsDisabled = true
    }
    
    func finishedOrganizing(events: [EKEvent], notOrganizedTasks: [Task], notParsableLines: [String]) {
        self.events = events
        manager.notOrganizedTasks = notOrganizedTasks
        manager.notParsableLines = notParsableLines
        if notOrganizedTasks.count > 0 {
            showingNotOrganizedTasksView = true
        }
        if notParsableLines.count > 0 {
            showingNotParsableLinesView = true
        }
        buttonsDisabled = false
    }
    
    func didNotFindValidMarkdown() {
        showingDidNotFindValidMarkdownActionSheet = true
        buttonsDisabled = false
    }
}

extension MainScreen: ExportToCalendarDelegate {
    func beginExport() {
        buttonsDisabled = true
    }
    
    func exportComplete(unexportedItems: [EKEvent], showActionSheet: Bool) {
        manager.notScheduledEvents = unexportedItems
        showingExportSuccessfulActionSheet = showActionSheet
        if manager.notScheduledEvents.count > 0 {
            showingNotScheduledEventsView = true
        }
        buttonsDisabled = false
        if UserDefaults().bool(forKey: UserDefaultsKeys.clearEventsAfterExport) {
            events = []
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
