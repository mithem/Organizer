//
//  shared.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import Foundation
import EventKit
import UIKit
import Intents

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
        _ = checkForCalendar(with: store)
    @unknown default:
        print("Unkown")
    }
}

func checkForCalendar(with store: EKEventStore) -> EKCalendar? {
    if let identifier = UserDefaults().string(forKey: UserDefaultsKeys.calendarIdentifier) {
        if let calendar = store.calendar(withIdentifier: identifier) {
            print("Found calendar.")
            return calendar
        } else {
            return createCalendar(with: store)
        }
    } else {
        return createCalendar(with: store)
    }
}

func createCalendar(with store: EKEventStore) -> EKCalendar? {
    /// https://nemecek.be/blog/45/how-to-create-new-calendar-using-eventkit-in-swift
    func bestPossibleEKSource() -> EKSource? {
        let `default` = store.defaultCalendarForNewEvents?.source
        let iCloud = store.sources.first(where: { $0.sourceType == .calDAV })
        let local = store.sources.first(where: { $0.sourceType == .local })
        return `default` ?? iCloud ?? local
    }
    
    let calendar = EKCalendar(for: .event, eventStore: store)
    calendar.title = "Organizer"
    calendar.source = bestPossibleEKSource()
    do {
        try store.saveCalendar(calendar, commit: true)
        UserDefaults().set(calendar.calendarIdentifier, forKey: "calendarIdentifier")
        print("Created calendar!")
    } catch {
        print("Error saving calendar: \(error)")
        return nil
    }
    return calendar
}

func parseAndOrganizeTasks(_ lines: [String], delegate: ParseAndOrganizeTasksDelegate, beginComponents: DateComponents, endComponents: DateComponents, store: EKEventStore) {
    func organize(with calendar: EKCalendar) {
        let organizer = EventOrganizer(dateComponentsForLimits: [(beginComponents, endComponents)], store: store)
        let (events, notOrganizedTasks) = organizer.organize(tasks: tasks, with: delegate.store, for: calendar) {
            delegate.updateProgress(0.33333 + ($0 * (Float(1) / Float(3))))
        }
        if let offset = delegate.alarmRelativeOffset {
            for i in 0..<events.count {
                let alarm = EKAlarm(relativeOffset: offset)
                events[i].addAlarm(alarm)
            }
        }
        delegate.finishedOrganizing(events: events, notOrganizedTasks: notOrganizedTasks, notParsableLines: notParsable)
    }
    let parser = MarkdownParser()
    var tasks = [Task]()
    var notParsable = [String]()
    for line in lines {
        let (t, notParsableLines) = parser.parseTasks(from: line, progressCallback: {delegate.updateProgress($0 * Float(1) / Float(3))})
        tasks.append(contentsOf: t)
        notParsable.append(contentsOf: notParsableLines)
    }
    if tasks.count == 0 {
        delegate.didNotFindValidMarkdown()
    } else {
        if let calendar = checkForCalendar(with: delegate.store) {
        organize(with: calendar)
        } else {
            // TODO: Error callback
        }
    }
}

func copyFromPasteboardAndOrganizeTasks(delegate: CopyFromPasteboardAndOrganizeTasksDelegate, beginComponents: DateComponents, endComponents: DateComponents, store: EKEventStore) {
    if UIPasteboard.general.hasStrings {
        if let strings = UIPasteboard.general.strings {
            parseAndOrganizeTasks(strings, delegate: delegate, beginComponents: beginComponents, endComponents: endComponents, store: store)
        }
    }
}

typealias CopyFromPasteboardAndOrganizeTasksDelegate = ParseAndOrganizeTasksDelegate

protocol ParseAndOrganizeTasksDelegate {
    var store: EKEventStore { get }
    var alarmRelativeOffset: TimeInterval? { get }
    
    func beginOrganizing()
    func finishedOrganizing(events: [EKEvent], notOrganizedTasks: [Task], notParsableLines: [String])
    func didNotFindValidMarkdown()
    func updateProgress(_ progress: Float)
}

func exportToCalendar(events: [EKEvent], delegate: ExportToCalendarDelegate, showCalendar: Bool? = nil) {
    DispatchQueue.global().async {
        delegate.beginExport()
    }
    var unexportedItems = [EKEvent]()
    var idx = 0
    for event in events {
        do {
            try delegate.store.save(event, span: EKSpan.thisEvent, commit: true)
            idx += 1
            delegate.updateProgress(0.66666 + ((Float(idx) / Float(events.count) / Float(3))))
        } catch {
            print(error)
            unexportedItems.append(event)
        }
    }
    if showCalendar == true || showCalendar == nil ? (UserDefaults().bool(forKey: UserDefaultsKeys.showCalendarAppAfterExport)) : false {
        guard let first = events.first else { delegate.exportComplete(unexportedItems: events, showActionSheet: false); return }
        let timestamp = first.startDate.timeIntervalSinceReferenceDate
        delegate.exportComplete(unexportedItems: unexportedItems, showActionSheet: false)
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string: "calshow:\(timestamp)")!)
        }
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

func getTapticNotificationType(eventsCount: Int, notScheduledEventsCount: Int, notOrganizedTasksCount: Int, notParsableLinesCount: Int) -> UINotificationFeedbackGenerator.FeedbackType {
    var warning = false
    var error = false
    
    // logic is hard🤔
    
    if eventsCount == 0 && notScheduledEventsCount == 0 && notOrganizedTasksCount == 0 && notParsableLinesCount == 0 {
        return .warning
    }
    
    if notScheduledEventsCount != 0 && notScheduledEventsCount != notOrganizedTasksCount {
        warning = true
    } else if notOrganizedTasksCount != 0 && notOrganizedTasksCount != notParsableLinesCount {
        warning = true
    } else if notParsableLinesCount != 0 {
        warning = true
    }
    
    if notParsableLinesCount != 0 && notOrganizedTasksCount == 0 {
        if notScheduledEventsCount == 0 {
            error = true
        } else {
            warning = true
        }
    } else if notOrganizedTasksCount != 0 && notScheduledEventsCount == 0 {
        error = true
    } else if notScheduledEventsCount != 0 {
        if eventsCount == 0 {
            error = true
        } else {
            warning = true
        }
    }
    
    if error {
        return .error
    } else if warning {
        return .warning
    }
    return .success
}

func getEventsForToday(from store: EKEventStore) -> [EKEvent] {
    var todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    let startDate = Calendar.current.date(from: todayComponents)!
    todayComponents.hour = 23
    todayComponents.minute = 59
    let endDate = Calendar.current.date(from: todayComponents)!
    let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
    var events = [EKEvent]()
    store.enumerateEvents(matching: predicate) { event, _ in
        events.append(event)
    }
    return events
}
