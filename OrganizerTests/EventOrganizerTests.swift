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
    
    let store = EKEventStore()
    let calendar = EKCalendar(for: .event, eventStore: EKEventStore())
    
    // MARK: Get limits
    func testGetLimits() {
        let organizer = EventOrganizer(dateComponentsForLimits: [(DateComponents(hour: 10), DateComponents(hour: 12))], store: store)
        
        let task = Task(title: "My task", date: Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23))!, time: 2700)
        
        let results = organizer._getLimits(for: task)
        
        let expectedLimit1 = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23, hour: 10))!
        let expected = [(expectedLimit1, expectedLimit1 + 7200)]
        
        XCTAssertEqual(results.count, expected.count)
        
        if results.count == expected.count {
            for idx in 0..<results.count {
                XCTAssertEqual(results[idx].0, expected[idx].0)
                XCTAssertEqual(results[idx].1, expected[idx].1)
            }
        }
    }
    
    func testGetLimits2() {
        let organizer = EventOrganizer(dateComponentsForLimits: [(DateComponents(hour: 0, minute: 0), .init(hour: 23, minute: 59))], store: store)
        
        let task = Task(title: "Some task", date: Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23))!, time: 600)
        
        let results = organizer._getLimits(for: task)
        
        let e1 = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23))!
        let e2 = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23, hour: 23, minute: 59))!
        let e = [(e1, e2)]
        
        XCTAssertEqual(results.count, e.count)
        
        if results.count == e.count {
            for i in 0..<results.count {
                XCTAssertEqual(results[i].0, e[i].0)
                XCTAssertEqual(results[i].1, e[i].1)
            }
        }
    }
    
    // MARK: Sort tasks
    func testSortTasks() {
        let organizer = EventOrganizer(dateComponentsForLimits: [], store: store) // irrelevant
        
        var dateComponents1 = DateComponents()
        dateComponents1.year = 2020
        dateComponents1.month = 8
        dateComponents1.day = 23
        
        var dateComponents2 = DateComponents()
        dateComponents2.year = 2020
        dateComponents2.month = 8
        dateComponents2.day = 25
        
        let day1 = Calendar.current.date(from: dateComponents1)!
        let day2 = Calendar.current.date(from: dateComponents2)!
        
        let t1 = Task(title: "Task 1", date: day2, time: 3600)
        let t2 = Task(title: "Task 2", date: day1, time: 1800)
        let t3 = Task(title: "Task 3", date: day2, time: 4000)
        let t4 = Task(title: "Task 4", date: day1, time: 2700)
        let t5 = Task(title: "Task 5", date: day2, time: 4500)
        let t6 = Task(title: "Task 6", date: day1, time: 200)
        
        let result = organizer._sortTasks([t1, t2, t3, t4, t5, t6])
        
        XCTAssertEqual(result, [t4, t2, t6, t5, t3, t1])
    }
    
    // MARK: Organize very simple
    func testOrganizeVerySimple() {
        
        let organizer = EventOrganizer(dateComponentsForLimits: [(DateComponents(hour: 0, minute: 0), DateComponents(hour: 23, minute: 59))], store: store, pauseEvery: 18000, pauseLength: 0)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        
        let tasks = [Task(title: "My task", date: date, time: 600)]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
        let e = EKEvent(eventStore: store)
        e.title = "My task"
        e.startDate = Calendar.current.date(from: dateComponents)!
        e.endDate = e.startDate + 600
        e.calendar = calendar
        
        let expected = [e]
        
        XCTAssertEqual(results.events, expected)
    }
    
    // MARK: Organize simple
    func testOrganizeSimple() {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 10)
        var end = DateComponents(hour: 11, minute: 45)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)], store: store)
        
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
    
    // MARK: Organize medium
    func testOrganizeMedium() {
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 9, minute: 15)
        var end = DateComponents(hour: 10, minute: 0)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)], store: store)
        
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
    
    // MARK: Organize medium+
    func testOrganizeMediumPlus() {
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 9, minute: 30)
        var end = DateComponents(hour: 12, minute: 0)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)], store: store)
        
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
    
    // MARK: Organize complex
    func testOrganizeComplex() {
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin1 = DateComponents(hour: 8)
        var end1 = DateComponents(hour: 10)
        var begin2 = DateComponents(hour: 11)
        var end2 = DateComponents(hour: 13)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin1, end1), (begin2, end2)], store: store)
        
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
    
    // MARK: Organize with pauses
    func testOrganizeWithPauses() {
        
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 23
        
        let date = Calendar.current.date(from: dateComponents)!
        var begin = DateComponents(hour: 8)
        var end = DateComponents(hour: 13)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)], store: store, pauseEvery: 7200, pauseLength: 3600)
        
        let tasks = [
            Task(title: "Session 1.1", date: date, time: 3600),
            Task(title: "Session 1.2", date: date, time: 3600),
            Task(title: "Session 2.1", date: date, time: 3600),
            Task(title: "Session 2.2", date: date, time: 3600)
        ]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
        begin.year = 2020
        begin.month = 8
        begin.day = 23
        end.year = 2020
        end.month = 8
        end.day = 23
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "Session 1.1"
        e1.calendar = calendar
        e1.startDate = Calendar.current.date(from: begin)!
        e1.endDate = e1.startDate + 3600
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "Session 1.2"
        e2.calendar = calendar
        e2.startDate = Calendar.current.date(from: begin)! + 3600
        e2.endDate = e2.startDate + 3600
        
        let e3 = EKEvent(eventStore: store)
        e3.title = "Session 2.1"
        e3.calendar = calendar
        e3.startDate = Calendar.current.date(from: end)! - 7200
        e3.endDate = e3.startDate + 3600
        
        let e4 = EKEvent(eventStore: store)
        e4.title = "Session 2.2"
        e4.calendar = calendar
        e4.startDate = Calendar.current.date(from: end)! - 3600
        e4.endDate = e4.startDate + 3600
        
        let expected = [e1, e2, e3, e4]
        
        XCTAssertEqual(results.events, expected)
    }
    
    // MARK: Different days in order
    func testOrganizeDifferentDaysInOrder() {
        
        var dateComponents1 = DateComponents()
        dateComponents1.year = 2020
        dateComponents1.month = 8
        dateComponents1.day = 23
        
        var dateComponents2 = DateComponents()
        dateComponents2.year = 2020
        dateComponents2.month = 8
        dateComponents2.day = 25
        
        let day1 = Calendar.current.date(from: dateComponents1)!
        let day2 = Calendar.current.date(from: dateComponents2)!
        var begin = DateComponents(hour: 8)
        var end = DateComponents(hour: 10)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)], store: store, pauseEvery: 7200, pauseLength: 3600)
        
        let tasks = [
            Task(title: "Day 1.1", date: day1, time: 3600),
            Task(title: "Day 1.2", date: day1, time: 3600),
            Task(title: "Day 2.1", date: day2, time: 3600),
            Task(title: "Day 2.2", date: day2, time: 3600)
        ]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
        begin.year = 2020
        begin.month = 8
        begin.day = 23
        end.year = 2020
        end.month = 8
        end.day = 25
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "Day 1.1"
        e1.calendar = calendar
        e1.startDate = Calendar.current.date(from: begin)!
        e1.endDate = e1.startDate + 3600
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "Day 1.2"
        e2.calendar = calendar
        e2.startDate = Calendar.current.date(from: begin)! + 3600
        e2.endDate = e2.startDate + 3600
        
        let e3 = EKEvent(eventStore: store)
        e3.title = "Day 2.1"
        e3.calendar = calendar
        e3.startDate = Calendar.current.date(from: end)! - 7200
        e3.endDate = e3.startDate + 3600
        
        let e4 = EKEvent(eventStore: store)
        e4.title = "Day 2.2"
        e4.calendar = calendar
        e4.startDate = Calendar.current.date(from: end)! - 3600
        e4.endDate = e4.startDate + 3600
        
        let expected = [e1, e2, e3, e4]
        
        XCTAssertEqual(results.events, expected)
    }
    
    // MARK: Different days out of order
    func testOrganizeDifferentDaysOutOfOrder() {
        
        var dateComponents1 = DateComponents()
        dateComponents1.year = 2020
        dateComponents1.month = 8
        dateComponents1.day = 23
        
        var dateComponents2 = DateComponents()
        dateComponents2.year = 2020
        dateComponents2.month = 8
        dateComponents2.day = 25
        
        let day1 = Calendar.current.date(from: dateComponents1)!
        let day2 = Calendar.current.date(from: dateComponents2)!
        var begin = DateComponents(hour: 8)
        var end = DateComponents(hour: 10)
        let organizer = EventOrganizer(dateComponentsForLimits: [(begin, end)], store: store, pauseEvery: 7200, pauseLength: 3600)
        
        let tasks = [
            Task(title: "Day 1.2", date: day1, time: 1800),
            Task(title: "Day 2.2", date: day2, time: 1800),
            Task(title: "Day 1.1", date: day1, time: 3600),
            Task(title: "Day 2.1", date: day2, time: 3600),
        ]
        
        let results = organizer.organize(tasks: tasks, with: store, for: calendar, progressCallback: {_ in})
        
        begin.year = 2020
        begin.month = 8
        begin.day = 23
        end.year = 2020
        end.month = 8
        end.day = 25
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "Day 1.1"
        e1.calendar = calendar
        e1.startDate = Calendar.current.date(from: begin)!
        e1.endDate = e1.startDate + 3600
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "Day 1.2"
        e2.calendar = calendar
        e2.startDate = Calendar.current.date(from: begin)! + 3600
        e2.endDate = e2.startDate + 1800
        
        let e3 = EKEvent(eventStore: store)
        e3.title = "Day 2.1"
        e3.calendar = calendar
        e3.startDate = Calendar.current.date(from: end)! - 7200
        e3.endDate = e3.startDate + 3600
        
        let e4 = EKEvent(eventStore: store)
        e4.title = "Day 2.2"
        e4.calendar = calendar
        e4.startDate = Calendar.current.date(from: end)! - 3600
        e4.endDate = e4.startDate + 1800
        
        let expected = [e1, e2, e3, e4]
        
        XCTAssertEqual(results.events, expected)
    }
    
    
    // MARK: _getDateComponentsForLimits
    
    
    func testGetDateComponentsForLimits1() {
        func dc(h: Int, m: Int = 0) -> DateComponents { DateComponents(hour: h, minute: m) }
        
        let originalDateComponents = [(dc(h: 10), dc(h: 16))]
        
        let d1 = Calendar.current.date(from: originalDateComponents[0].0)!
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "e1"
        e1.startDate = d1 + 3600
        e1.endDate = e1.startDate + 3600
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "e2"
        e2.startDate = e1.endDate + 15 * 60
        e2.endDate = e2.startDate + 1800
        
        let events = [e1, e2]
        
        let result = EventOrganizer._getDateComponentsForLimits(fromEvents: events, originalComponents: originalDateComponents)
        
        let expected = [(dc(h: 10), dc(h:11)), (dc(h: 12), dc(h: 12, m: 15)), (dc(h: 12, m: 45), dc(h: 16))]
        
        XCTAssertTrue(result.count == expected.count)
        
        if result.count == expected.count {
            for i in 0 ..< result.count {
                XCTAssertEqual(result[i].0, expected[i].0)
                XCTAssertEqual(result[i].1, expected[i].1)
            }
        }
    }
    
    func testGetDateComponentsForLimits2() {
        func dc(h: Int, m: Int = 0) -> DateComponents { DateComponents(hour: h, minute: m) }
        
        let originalDateComponents = [(dc(h: 10), dc(h: 16))]
        
        let d1 = Calendar.current.date(from: originalDateComponents[0].0)!
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "e1"
        e1.startDate = d1
        e1.endDate = e1.startDate + 3600
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "e2"
        e2.startDate = e1.endDate + 1800
        e2.endDate = e2.startDate + 1800
        
        let events = [e1, e2]
        
        let result = EventOrganizer._getDateComponentsForLimits(fromEvents: events, originalComponents: originalDateComponents)
        
        let expected = [(dc(h: 11), dc(h:11, m: 30)), (dc(h: 12), dc(h: 16))]
        
        XCTAssertTrue(result.count == expected.count)
        
        if result.count == expected.count {
            for i in 0 ..< result.count {
                XCTAssertEqual(result[i].0, expected[i].0)
                XCTAssertEqual(result[i].1, expected[i].1)
            }
        }
    }
    
    func testGetDateComponentsForLimits3() {
        func dc(h: Int, m: Int = 0) -> DateComponents { DateComponents(hour: h, minute: m) }
        
        let originalDateComponents = [(dc(h: 10), dc(h: 16))]
        
        let d1 = Calendar.current.date(from: originalDateComponents[0].0)!
        
        let e1 = EKEvent(eventStore: store)
        e1.title = "e1"
        e1.startDate = d1
        e1.endDate = e1.startDate + 3600
        
        let e2 = EKEvent(eventStore: store)
        e2.title = "e2"
        e2.startDate = e1.endDate + 3600
        e2.endDate = e2.startDate + 3600
        
        let e3 = EKEvent(eventStore: store)
        e3.title = "e3"
        e3.startDate = e2.endDate
        e3.endDate = e3.startDate + 3600
        
        let e4 = EKEvent(eventStore: store)
        e4.title = "e4"
        e4.startDate = e3.endDate
        e4.endDate = e4.startDate + 3600
        
        let events = [e1, e2, e3, e4]
        
        let result = EventOrganizer._getDateComponentsForLimits(fromEvents: events, originalComponents: originalDateComponents)
        
        let expected = [(dc(h: 11), dc(h: 12)), (dc(h: 15), dc(h: 16))]
        
        XCTAssertTrue(result.count == expected.count)
        
        if result.count == expected.count {
            for i in 0 ..< result.count {
                XCTAssertEqual(result[i].0, expected[i].0)
                XCTAssertEqual(result[i].1, expected[i].1)
            }
        }
    }
    
    func testGetDateComponentsForLimits4() {
        func dc(h: Int, m: Int = 0) -> DateComponents { DateComponents(hour: h, minute: m) }
        
        let originalComponents = [(dc(h: 0), dc(h:23, m:59))]
        
        let d1 = Calendar.current.date(from: originalComponents[0].0)!
        
        let e = EKEvent(eventStore: store)
        e.title = "Event"
        e.startDate = d1
        e.endDate = e.startDate + 600
        
        let result = EventOrganizer._getDateComponentsForLimits(fromEvents: [e], originalComponents: originalComponents)
        
        let expected = [(dc(h: 0, m: 10), dc(h: 23, m: 59))]
        
        XCTAssertEqual(result.count, expected.count)
        
        if result.count == expected.count {
            for i in 0..<result.count {
                XCTAssertEqual(result[i].0, expected[i].0)
                XCTAssertEqual(result[i].1, expected[i].1)
            }
        }
    }
}
