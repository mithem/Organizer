//
//  EventOrganizerTests.swift
//  OrganizerTests
//
//  Created by Miguel Themann on 23.08.20.
//

import XCTest
import EventKit
@testable import Organizer

class EventOrganizerTests: XCTestCase {
    
    let organizer = EventOrganizer()
    
    func testOrganizeVerySimple() {
        
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.nanosecond = 0
        
        let date = Calendar.current.date(from: dateComponents)!
        
        let tasks = [Task(title: "My task", date: date, time: 10 * 60)]
        
        let results = organizer.organize(tasks: tasks, limits: [(DateComponents(hour: 0, minute: 0), DateComponents(hour: 23, minute: 59))], with: store, for: calendar)
        
        let e = EKEvent(eventStore: store)
        e.title = "My task"
        e.startDate = date
        e.endDate = date + 10 * 60
        e.calendar = calendar
        
        let expected = [e]
        
        XCTAssertEqual(results, expected)
    }
    
    func testOrganizeSimple() {
        
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.nanosecond = 0
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 9, minute: 15)
        var end = DateComponents(hour: 10, minute: 0)
        
        let tasks = [Task(title: "Another Task!", date: date, time: 60 * 60), Task(title: "Hello, there!", date: date, time: 45 * 60)]
        
        let results = organizer.organize(tasks: tasks, limits: [(begin, end)], with: store, for: calendar)
        
        begin.year = 2020
        begin.month = 8
        begin.day = 23
        end.year = 2020
        end.month = 8
        end.day = 23
        
        let e = EKEvent(eventStore: store)
        e.title = "Hello, there!"
        e.startDate = Calendar.current.date(from: begin)!
        e.endDate = Calendar.current.date(from: end)!
        e.calendar = calendar
        
        let expected = [e]
        
        XCTAssertEqual(results, expected)
    }
    
    func testOrganizeMedium() {
        
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.nanosecond = 0
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 9, minute: 30)
        var end = DateComponents(hour: 12, minute: 0)
        
        let tasks = [Task(title: "Another Task!", date: date, time: 60 * 60), Task(title: "Hello, there!", date: date, time: 45 * 60), Task(title: "🚀🎉✈️", date: date, time: 45 * 60), Task(title: "Shouldn't be included..", date: date, time: 10 * 60)]
        
        let results = organizer.organize(tasks: tasks, limits: [(begin, end)], with: store, for: calendar)
        
        begin.year = 2020
        begin.month = 8
        begin.day = 23
        end.year = 2020
        end.month = 8
        end.day = 23
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "Another Task!"
        e1.startDate = Calendar.current.date(from: begin)!
        e1.endDate = Calendar.current.date(from: begin)! + (60 * 60)
        e1.calendar = calendar
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "Hello, there!"
        e2.startDate = Calendar.current.date(from: begin)! + (60 * 60)
        e2.endDate = Calendar.current.date(from: begin)! + (60 * 60) + (45 * 60)
        e2.calendar = calendar
        
        let e3 = EKEvent(eventStore: store)
        e3.title = "🚀🎉✈️"
        e3.startDate = Calendar.current.date(from: begin)! + (60 * 60) + (45 * 60)
        e3.endDate = Calendar.current.date(from: begin)! + (60 * 60) + (45 * 60 * 2)
        e3.calendar = calendar
        
        let expected = [e1, e2, e3]
        
        XCTAssertEqual(results, expected)
    }
}
