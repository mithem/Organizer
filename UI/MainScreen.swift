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
    @State private var showingDidNotFindValidMarkdownActionSheet = false
    @State private var buttonsDisabled = false
    @State private var showingExportSuccessfulActionSheet = false
    
    let store = EKEventStore()
    let calendar: EKCalendar?
    
    init() {
        if let identifier = UserDefaults().string(forKey: "calendarIdentifier") {
            if let calendar = store.calendar(withIdentifier: identifier) {
                self.calendar = calendar
            } else {
                calendar = nil
                createCalendar()
            }
        } else {
            calendar = nil
            createCalendar()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    copyFromPasteboard()
                }) {
                    Text("Paste from clipboard/pasteboard")
                        .foregroundColor(buttonsDisabled ? .gray : .blue)
                        .onAppear(perform: checkAuthStatus)
                }
                .disabled(buttonsDisabled)
                ForEach(events) { event in
                    HStack {
                        Text(event.title)
                        Spacer()
                        Text(event.timeInterval)
                    }
                }
                Button(action: {
                    exportToCalendar()
                }) {
                    Text("Export to Calendar")
                        .foregroundColor(buttonsDisabled ? .gray : .blue)
                }
                .disabled(buttonsDisabled)
                .actionSheet(isPresented: $showingExportSuccessfulActionSheet) {
                    ActionSheet(title: Text("Export successful"), message: Text("Exported tasks to calendar."), buttons: [.default(Text("OK"))])
                }
            }
            .navigationBarItems(trailing: NavigationLink("Settings", destination: SettingsView()))
            .navigationTitle("Organizer")
            .actionSheet(isPresented: $showingDidNotFindValidMarkdownActionSheet) {
                ActionSheet(title: Text("No data found"), message: Text("Unable to find valid markdown from Things."), buttons: [.default(Text("OK"))])
            }
        }
    }
    
    func exportToCalendar() {
        for event in events {
            do {
                try store.save(event, span: EKSpan.thisEvent, commit: true)
                print("Saved event.")
            } catch {
                print(error)
            }
        }
        if UserDefaults().bool(forKey: "showCalendarAppAfterExport") {
            let timestamp = events.first!.startDate.timeIntervalSinceReferenceDate
            UIApplication.shared.open(URL(string: "calshow:\(timestamp)")!)
        } else {
            showingExportSuccessfulActionSheet = true
        }
        buttonsDisabled = false
    }
    
    func copyFromPasteboard() {
        var tasks = [Task]()
        if UIPasteboard.general.hasStrings {
            if let strings = UIPasteboard.general.strings {
                let parser = MarkdownParser()
                for string in strings {
                    tasks.append(contentsOf: parser.parseTasks(from: string))
                }
                
            }
        }
        if tasks.count == 0 {
            showingDidNotFindValidMarkdownActionSheet = true
        } else {
            if let calendar = calendar {
                let organizer = EventOrganizer()
                events = organizer.organize(tasks: tasks, limits: [(DateComponents(hour: 14, minute: 30), DateComponents(hour: 20, minute: 0))], with: store, for: calendar)
            }
        }
        buttonsDisabled = false
    }
    
    func createCalendar() {
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = "Organizer"
        calendar.source = store.sources.filter{
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.local.rawValue
        }.first ?? store.sources.first
        do {
            try store.saveCalendar(calendar, commit: true)
            UserDefaults().set(calendar.calendarIdentifier, forKey: "calendarIdentifier")
            print("Created calendar!")
        } catch {
            print("Error saving calendar: \(error)")
        }
    }
    
    func checkAuthStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            print("Not determined")
            store.requestAccess(to: .event) { success, error in
                if success {
                    createCalendar()
                } else {
                    print("Unsucessful")
                }
                if let error = error {
                    print("Error: \(error)")
                }
            }
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorized:
            print("Authorized")
        @unknown default:
            print("Unkown")
        }
    }
    
    func exportToCalendar(events: [EKEvent], with store: EKEventStore) {
        for event in events {
            do {
                try store.save(event, span: EKSpan.thisEvent, commit: true)
                print("Saved event.")
            } catch {
                print(error)
            }
        }
    }
    
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
