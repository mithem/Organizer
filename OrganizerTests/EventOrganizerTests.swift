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
    
    func testGetLimits() {
        let organizer = EventOrganizer(dateComponentsForLimits: [(DateComponents(hour: 10), DateComponents(hour: 12))])
        
        let task = Task(title: "My task", date: Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23))!, time: 2700)
        
        let results = organizer._getLimits(for: task)
        
        let expectedLimit1 = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23, hour: 10))!
        let expected = [(expectedLimit1, expectedLimit1 + 7200)]
        
        for idx in 0..<results.count {
            XCTAssertEqual(results[idx].0, expected[idx].0)
            XCTAssertEqual(results[idx].1, expected[idx].1)
        }
    }
    
    func testOrganizeVerySimple() {
        
        let organizer = EventOrganizer(dateComponentsForLimits: [(DateComponents(hour: 0, minute: 0), DateComponents(hour: 23, minute: 59))])
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        
        let tasks = [Task(title: "My task", date: date, time: 10 * 60)]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
        let e = EKEvent(eventStore: store)
        e.title = "My task"
        e.startDate = Calendar.current.date(from: dateComponents)!
        e.endDate = e.startDate + 10 * 60
        e.calendar = calendar
        
        let expected = [e]
        
        XCTAssertEqual(results.events, expected)
    }
    
    func testOrganizeSimple() {
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 10)
        var end = DateComponents(hour: 11, minute: 45)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)])
        
        begin.year = 2020
        begin.month = 8
        begin.day = 23
        end.year = 2020
        end.month = 8
        end.day = 23
        
        let tasks = [
            Task(title: "Some important task", date: date, time: 3600),
            Task(title: "Another one!", date: date + 3600, time: 2700)
        ]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "Some important task"
        e1.startDate = Calendar.current.date(from: begin)
        e1.endDate = e1.startDate + tasks.first!.time
        e1.calendar = calendar
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "Another one!"
        e2.startDate = e1.endDate
        e2.endDate = Calendar.current.date(from: end)
        e2.calendar = calendar
        
        let expected = [e1, e2]
        
        XCTAssertEqual(results.events, expected)
    }
    
    func testOrganizeMedium() {
        
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 9, minute: 15)
        var end = DateComponents(hour: 10, minute: 0)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)])
        
        let tasks = [
            Task(title: "Another Task!", date: date, time: 60 * 60),
            Task(title: "Hello, there!", date: date, time: 45 * 60)
        ]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
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
        
        XCTAssertEqual(results.events, expected)
        
        XCTAssertEqual(results.notOrganizedTasks, [tasks.first!])
    }
    
    func testOrganizeMediumPlus() {
        
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 9, minute: 30)
        var end = DateComponents(hour: 12, minute: 0)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)])
        
        let tasks = [
            Task(title: "Another Task!", date: date, time: 60 * 60),
            Task(title: "Hello, there!", date: date, time: 45 * 60),
            Task(title: "🚀🎉✈️", date: date, time: 45 * 60),
            Task(title: "One day later...", date: date, time: 10 * 60)
        ]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
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
        
        XCTAssertEqual(results.events, expected)
        
        XCTAssertEqual(results.notOrganizedTasks, [tasks.last!])
    }
    
    func testOrganizeComplex() {
        
        let store = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: store)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin1 = DateComponents(hour: 8)
        var end1 = DateComponents(hour: 10)
        var begin2 = DateComponents(hour: 11)
        var end2 = DateComponents(hour: 13)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin1, end1), (begin2, end2)])
        
        let tasks = [
            Task(title: "Session 1", date: date, time: 7200),
            Task(title: "Session 2", date: date, time: 7200)
        ]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
        begin1.year = 2020
        begin1.month = 8
        begin1.day = 23
        begin2.year = 2020
        begin2.month = 8
        begin2.day = 23
        end1.year = 2020
        end1.month = 8
        end1.day = 23
        end2.year = 2020
        end2.month = 8
        end2.day = 23
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "Session 1"
        e1.startDate = Calendar.current.date(from: begin1)
        e1.endDate = Calendar.current.date(from: end1)
        e1.calendar = calendar
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "Session 2"
        e2.startDate = Calendar.current.date(from: begin2)
        e2.endDate = Calendar.current.date(from: end2)
        e2.calendar = calendar
        
        let expected = [e1, e2]
        
        XCTAssertEqual(results.events, expected)
        
        XCTAssertEqual(results.notOrganizedTasks, [])
    }
}
