//
//  MainScreen.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import SwiftUI
import EventKit

struct MainScreen: View {
    @ObservedObject var exportReportDataManager = ExportReportDataManager()
    
    @State private var showingDidNotFindValidMarkdownActionSheet = false
    @State private var buttonsDisabled = false
    
    @State private var showingInvalidBeginAndEndActionSheet = false
    @State private var showingEventsFoundInCalendarActionSheet = false
    
    @State private var beginning = Date(timeIntervalSinceNow: 0)
    @State private var end = Date(timeIntervalSinceNow: 15 * 60)
    
    @State private var events = [EKEvent]()
    
    @State private var progressValue: Float = 0
    @State private var progressDescription = "Parse first."
    
    @State private var showingExportReportView = false
    @State private var showingOnboardingView = false
    
    @AppStorage(UserDefaultsKeys.eventAlarmOffset) var alarmRelativeOffsetString = EventAlarmOffset.none.rawValue
    @AppStorage(UserDefaultsKeys.considerCalendarEventsWhenOrganizing) var considerCalendarEvents = DefaultSettings.considerCalendarEventsWhenOrganizing
    
    let store = EKEventStore()
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                Toggle("Consider calendar events", isOn: $considerCalendarEvents)
                HStack {
                    Text("Beginning")
                    DatePicker("Beginning", selection: $beginning, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .actionSheet(isPresented: $showingDidNotFindValidMarkdownActionSheet) {
                            ActionSheet(title: Text("No data found"), message: Text("Unable to find valid markdown from Things."), buttons: [.default(Text("OK"))])
                        }
                        .accessibility(label: Text("Start time"))
                        .accessibilityAction(named: Text("Set start time to now"), {beginning = Date(timeIntervalSinceNow: 0)})
                }
                HStack {
                    Text("End")
                    DatePicker("End", selection: $end, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .actionSheet(isPresented: $showingInvalidBeginAndEndActionSheet) {
                            ActionSheet(title: Text("Invalid beginning & end"), message: Text("Please make sure that the end date is later than beginning."), buttons: [.default(Text("OK"))])
                        }
                        .accessibility(label: Text("End time"))
                        .accessibilityAction(named: Text("Set end time to in 15 minutes"), {end = Date(timeIntervalSinceNow: 15 * 60)})
                        .accessibilityAction(named: Text("Set end time to in 1 hour"), {end = Date(timeIntervalSinceNow: 3600)})
                }
                VStack {
                    ProgressView(value: progressValue)
                        .animation(.easeInOut)
                        .accessibility(identifier: "ProgressBar")
                        .actionSheet(isPresented: $showingEventsFoundInCalendarActionSheet) {
                            ActionSheet(title: Text("Events found in calendar."), message: Text("How do you want to proceed?"), buttons: [.default(Text("Consider it/them")) {
                                considerCalendarEvents = true
                                parseFromPasteboardAndOrganize()
                            }, .cancel(Text("Ignore")) {
                                considerCalendarEvents = false
                                parseFromPasteboardAndOrganize()
                            }])
                        }
                        .sheet(isPresented: $showingExportReportView) {
                            ExportReportView(manager: exportReportDataManager, store: store)
                        }
                    HStack {
                        Spacer()
                        Text(progressDescription)
                            .foregroundColor(.secondary)
                            .accessibility(label: Text("Progress description"))
                            .accessibility(value: Text(progressDescription))
                        Spacer()
                    }
                    .sheet(isPresented: $showingOnboardingView) {
                        OnboardingView()
                    }
                }
                Button("Parse from clipboard/pasteboard") {
                    parseFromPasteboardAndOrganize()
                }
                .accessibility(hint: Text("Parse tasks from clipboard, organize them, and export to your calendar"))
                .onAppear {
                    checkAuthStatus(with: store)
                    showingOnboardingView = !UserDefaults().bool(forKey: UserDefaultsKeys.didShowOnboardingView)
                }
            }
            .navigationBarItems(trailing: NavigationLink("Settings", destination: SettingsView()))
            .navigationTitle("Organizer")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func parseFromPasteboardAndOrganize() {
        progressDescription = "Parsing tasks"
        progressValue = 0
        let beginComponents = Calendar.current.dateComponents([.hour, .minute], from: beginning)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: end)
        
        if beginning >= end {
            showingInvalidBeginAndEndActionSheet = true
        } else {
            DispatchQueue.global().async { // So progress bar can update on main thread
                exportReportDataManager.reset()
                copyFromPasteboardAndOrganizeTasks(delegate: self, beginComponents: beginComponents, endComponents: endComponents, store: store)
            }
        }
    }
}

extension MainScreen: ParseAndOrganizeTasksDelegate {
    var alarmRelativeOffset: TimeInterval? {
        (EventAlarmOffset(rawValue: alarmRelativeOffsetString) ?? .none).timeInterval
    }
    
    func updateProgress(_ progress: Float) {
        progressValue = progress
    }
    
    func beginOrganizing() {
        progressValue = 0.33333
        progressDescription = "Organizing events"
        buttonsDisabled = true
    }
    
    func finishedOrganizing(events: [EKEvent], notOrganizedTasks: [Task], notParsableLines: [String]) {
        progressValue = 0.66666
        DispatchQueue.main.async {
            exportReportDataManager.notOrganizedTasks = notOrganizedTasks
            exportReportDataManager.notParsableLines = notParsableLines
            exportReportDataManager.exportedEvents = events
        }
        self.events = events
        
        exportToCalendar(events: self.events, delegate: self, showCalendar: (notOrganizedTasks.isEmpty && notParsableLines.isEmpty) ? nil : false)
        
        showingExportReportView = true
        
        feedbackGenerator.prepare()
    }
    
    func didNotFindValidMarkdown() {
        showingDidNotFindValidMarkdownActionSheet = true
        progressDescription = "Parse first."
    }
}

extension MainScreen: ExportToCalendarDelegate {
    func beginExport() {
        progressDescription = "Exporting \(events.count) events"
        if events.count > 10 { // approximately, of course..
            feedbackGenerator.prepare()
        }
    }
    
    func exportComplete(unexportedItems: [EKEvent], showActionSheet: Bool) {
        progressValue = 1
        
        DispatchQueue.main.async {
            exportReportDataManager.notScheduledEvents = unexportedItems
        }
        
        progressDescription = "Exported \(events.count - unexportedItems.count) events."
        
        feedbackGenerator.notificationOccurred(getTapticNotificationType(eventsCount: events.count, notScheduledEventsCount: unexportedItems.count, notOrganizedTasksCount: exportReportDataManager.notOrganizedTasks.count, notParsableLinesCount: exportReportDataManager.notParsableLines.count))
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
