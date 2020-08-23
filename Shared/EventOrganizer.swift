//
//  EventOrganizer.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 23.08.20.
//

import Foundation
import EventKit

struct EventOrganizer {
    func organize(tasks: [Task], limits: [(DateComponents, DateComponents)], with store: EKEventStore, for calendar: EKCalendar) -> [EKEvent] {
        var events = [EKEvent]()
        var previousEndDate: Date?
        let sorted = tasks.sorted()
        for task in sorted {
            for (components1, components2) in limits {
                let taskDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: task.date)
                
                var limit1Components = DateComponents()
                limit1Components.year = taskDateComponents.year
                limit1Components.month = taskDateComponents.month
                limit1Components.day = taskDateComponents.day
                limit1Components.hour = components1.hour
                limit1Components.minute = components1.minute
                
                var limit2Components = DateComponents()
                limit2Components.year = taskDateComponents.year
                limit2Components.month = taskDateComponents.month
                limit2Components.day = taskDateComponents.day
                limit2Components.hour = components2.hour
                limit2Components.minute = components2.minute
                
                guard let limit1 = Calendar.current.date(from: limit1Components) else { return events }
                guard let limit2 = Calendar.current.date(from: limit2Components) else { return events }
                
                let possibleStartDate = previousEndDate ?? limit1
                let endDate = possibleStartDate + task.time
                if endDate > limit2 {
                    continue
                } else {
                    let event = EKEvent(eventStore: store)
                    event.calendar = calendar
                    event.startDate = possibleStartDate
                    event.endDate = endDate
                    previousEndDate = endDate
                    event.title = task.title
                    events.append(event)
                }
            }
        }
        return events
    }
}
