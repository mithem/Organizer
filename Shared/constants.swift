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

let tasksForPreview = [Task(title: "My 1st task!", date: Date() + 60, time: 180), Task(title: "Another one!", date: Date() + 1800, time: 600)]

struct UserDefaultsKeys {
    static let showCalendarAppAfterExport = "showCalendarAppAfterExport"
    static let pauseEveryTimeInterval = "pauseEveryTimeInterval"
    static let pauseLengthTimeInterval = "pauseLengthTimeInterval"
    static let didShowOnboardingView = "didShowOnboardingView"
    static let eventAlarmOffset = "eventAlarmOffset"
    static let considerCalendarEventsWhenOrganizing = "considerCalendarEventsWhenOrganizing"
    static let calendarIdentifier = "calendarIdentifier"
}

struct DefaultSettings {
    static let considerCalendarEventsWhenOrganizing = false
}
