//
//  MainScreen.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import SwiftUI
import EventKit

struct MainScreen: View {
    @State private var showingDidNotFindValidMarkdownActionSheet = false
    @State private var buttonsDisabled = false
    @State private var showingExportSuccessfulActionSheet = false
    
    @State private var beginning = Date(timeIntervalSinceNow: 0)
    @State private var end = Date(timeIntervalSinceNow: 15 * 60)
    
    @State private var events = [EKEvent]()
    
    @State private var progressValue: Float = 0
    @State private var progressDescription = "Parse first."
    
    @State private var pauseEvery = PauseEveryTimeInterval.h2
    
    @ObservedObject var unsuccessfulDataManager = UnsuccessfulDataManager()
    
    @State private var showingUnsuccessfulDataView = false
    
    let store = EKEventStore()
    
    init() {
        checkAuthStatus(with: store)
    }
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Beginning", selection: $beginning, displayedComponents: [.hourAndMinute])
                DatePicker("End", selection: $end, displayedComponents: [.hourAndMinute])
                VStack {
                    ProgressView(value: progressValue)
                        .animation(.easeInOut)
                    HStack {
                        Spacer()
                        Text(progressDescription)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                Button("Parse from clipboard/pasteboard") {
                    parseFromPasteboardAndOrganize()
                }
                .sheet(isPresented: $showingUnsuccessfulDataView) {
                    UnsuccessfulDataView(manager: unsuccessfulDataManager)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing: NavigationLink("Settings", destination: SettingsView()))
            .navigationTitle("Organizer")
            .actionSheet(isPresented: $showingDidNotFindValidMarkdownActionSheet) {
                ActionSheet(title: Text("No data found"), message: Text("Unable to find valid markdown from Things."), buttons: [.default(Text("OK"))])
            }
        }
    }
    
    func parseFromPasteboardAndOrganize() {
        progressDescription = "Parsing tasks"
        let beginComponents = Calendar.current.dateComponents([.hour, .minute], from: beginning)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: end)
        copyFromPasteboardAndOrganizeTasks(delegate: self, beginComponents: beginComponents, endComponents: endComponents)
    }
}

extension MainScreen: CopyFromPasteboardAndOrganizeTasksDelegate {
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
        unsuccessfulDataManager.notOrganizedTasks = notOrganizedTasks
        unsuccessfulDataManager.notParsableLines = notParsableLines
        self.events = events
        
        exportToCalendar(events: self.events, delegate: self)
    }
    
    func didNotFindValidMarkdown() {
        showingDidNotFindValidMarkdownActionSheet = true
    }
}

extension MainScreen: ExportToCalendarDelegate {
    func beginExport() {
        progressDescription = "Exporting \(events.count) events"
    }
    
    func exportComplete(unexportedItems: [EKEvent], showActionSheet: Bool) {
        progressValue = 1
        unsuccessfulDataManager.notScheduledEvents = unexportedItems
        if showActionSheet && unexportedItems.count < events.count {
            showingExportSuccessfulActionSheet = true
        }
        progressDescription = "Exported \(events.count - unexportedItems.count) events."
        if unsuccessfulDataManager.hasItems {
            showingUnsuccessfulDataView = true
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
