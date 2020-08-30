//
//  constants.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 30.08.20.
//

import Foundation
import EventKit

var eventsForPreview: [EKEvent] {
    var events = [EKEvent]()
    var event = EKEvent()
    event.title = "Hello there!"
    event.startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23, hour: 12, minute: 30))
    event.endDate = event.startDate + 3600
    events.append(event)
    
    event = EKEvent()
    event.title = "Another event!"
    event.startDate = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23, hour: 14, minute: 12))
    event.endDate = event.startDate + 2700
    events.append(event)
    
    return events
}

struct UserDefaultsKeys {
    static let showCalendarAppAfterExport = "showCalendarAppAfterExport"
    static let clearEventsAfterExport = "clearEventsAfterExport"
}
