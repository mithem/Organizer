//
//  shared.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import Foundation
import EventKit
import UIKit

func checkAuthStatus(with store: EKEventStore) {
    let status = EKEventStore.authorizationStatus(for: .event)
    switch status {
    case .notDetermined:
        print("Not determined")
        store.requestAccess(to: .event) { success, error in
            if success {
                checkForCalendar(with: store) { _ in }
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

func checkForCalendar(with store: EKEventStore, callback: (EKCalendar) -> Void) {
    if let identifier = UserDefaults().string(forKey: "calendarIdentifier") {
        if let calendar = store.calendar(withIdentifier: identifier) {
            callback(calendar)
        } else {
            return createCalendar(with: store)
        }
    } else {
        return createCalendar(with: store)
    }
}

func createCalendar(with store: EKEventStore) {
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

func copyFromPasteboardAndOrganizeTasks(delegate: CopyFromPasteboardAndOrganizeTasksDelegate, beginComponents: DateComponents, endComponents: DateComponents) {
    var tasks = [Task]()
    var notParsable = [String]()
    if UIPasteboard.general.hasStrings {
        if let strings = UIPasteboard.general.strings {
            let parser = MarkdownParser()
            for string in strings {
                let (t, notParsableLines) = parser.parseTasks(from: string)
                tasks.append(contentsOf: t)
                notParsable.append(contentsOf: notParsableLines)
            }
            
        }
    }
    if tasks.count == 0 {
        delegate.didNotFindValidMarkdown()
    } else {
        if let calendar = delegate.calendar {
            let organizer = EventOrganizer(dateComponentsForLimits: [(beginComponents, endComponents)])
            let (events, notOrganizedTasks) = organizer.organize(tasks: tasks, with: delegate.store, for: calendar)
            delegate.finishedOrganizing(events: events, notOrganizedTasks: notOrganizedTasks, notParsableLines: notParsable)
        }
    }
}

protocol CopyFromPasteboardAndOrganizeTasksDelegate {
    var calendar: EKCalendar? { get }
    var store: EKEventStore { get }
    
    func beginOrganizing()
    func finishedOrganizing(events: [EKEvent], notOrganizedTasks: [Task], notParsableLines: [String])
    func didNotFindValidMarkdown()
}

func exportToCalendar(events: [EKEvent], delegate: ExportToCalendarDelegate) {
    delegate.beginExport()
    var unexportedItems = [EKEvent]()
    for event in events {
        do {
            try delegate.store.save(event, span: EKSpan.thisEvent, commit: true)
            print("Saved event.")
        } catch {
            print(error)
            unexportedItems.append(event)
        }
    }
    if UserDefaults().bool(forKey: UserDefaultsKeys.showCalendarAppAfterExport) {
        let timestamp = events.first!.startDate.timeIntervalSinceReferenceDate
        delegate.exportComplete(unexportedItems: unexportedItems, showActionSheet: false)
        UIApplication.shared.open(URL(string: "calshow:\(timestamp)")!)
    } else {
        delegate.exportComplete(unexportedItems: unexportedItems, showActionSheet: unexportedItems.count == 0 ? true : false)
    }
}

protocol ExportToCalendarDelegate {
    var store: EKEventStore { get }
    
    func beginExport()
    func exportComplete(unexportedItems: [EKEvent], showActionSheet: Bool)
}
