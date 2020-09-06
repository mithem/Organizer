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
                _ = checkForCalendar(with: store)
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

func checkForCalendar(with store: EKEventStore) -> EKCalendar {
    if let identifier = UserDefaults().string(forKey: "calendarIdentifier") {
        if let calendar = store.calendar(withIdentifier: identifier) {
            return calendar
        } else {
            return createCalendar(with: store)
        }
    } else {
        return createCalendar(with: store)
    }
}

func createCalendar(with store: EKEventStore) -> EKCalendar {
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
    return calendar
}

func copyFromPasteboardAndOrganizeTasks(delegate: CopyFromPasteboardAndOrganizeTasksDelegate, beginComponents: DateComponents, endComponents: DateComponents) {
    func organize(with calendar: EKCalendar) {
        let organizer = EventOrganizer(dateComponentsForLimits: [(beginComponents, endComponents)])
        let (events, notOrganizedTasks) = organizer.organize(tasks: tasks, with: delegate.store, for: calendar, progressCallback: {delegate.updateProgress(0.33333 + ($0 * Float(1/3)))})
        delegate.finishedOrganizing(events: events, notOrganizedTasks: notOrganizedTasks, notParsableLines: notParsable)
    }
    var tasks = [Task]()
    var notParsable = [String]()
    if UIPasteboard.general.hasStrings {
        if let strings = UIPasteboard.general.strings {
            let parser = MarkdownParser()
            for string in strings {
                let (t, notParsableLines) = parser.parseTasks(from: string, progressCallback: {delegate.updateProgress($0 * Float(1 / 3))})
                tasks.append(contentsOf: t)
                notParsable.append(contentsOf: notParsableLines)
            }
            
        }
    }
    if tasks.count == 0 {
        delegate.didNotFindValidMarkdown()
    } else {
        let calendar = checkForCalendar(with: delegate.store)
        organize(with: calendar)
    }
}

protocol CopyFromPasteboardAndOrganizeTasksDelegate {
    var store: EKEventStore { get }
    
    func beginOrganizing()
    func finishedOrganizing(events: [EKEvent], notOrganizedTasks: [Task], notParsableLines: [String])
    func didNotFindValidMarkdown()
    func updateProgress(_ progress: Float)
}

func exportToCalendar(events: [EKEvent], delegate: ExportToCalendarDelegate) {
    delegate.beginExport()
    var unexportedItems = [EKEvent]()
    var idx = 0
    for event in events {
        do {
            try delegate.store.save(event, span: EKSpan.thisEvent, commit: true)
            idx += 1
            delegate.updateProgress(0.66666 + (Float(idx) / Float(events.count)))
        } catch {
            print(error)
            unexportedItems.append(event)
        }
    }
    if UserDefaults().bool(forKey: UserDefaultsKeys.showCalendarAppAfterExport) {
        guard let first = events.first else { delegate.exportComplete(unexportedItems: events, showActionSheet: false); return }
        let timestamp = first.startDate.timeIntervalSinceReferenceDate
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
    func updateProgress(_ progress: Float)
}
