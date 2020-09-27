//
//  OrganizerTests.swift
//  OrganizerTests
//
//  Created by Miguel Themann on 18.09.20.
//

import XCTest
@testable import Organizer

class OrganizerTests: XCTestCase {
    
    let day1 = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23, hour: 12))!
    let day2 = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 24, hour: 12))!
    let day3 = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 25, hour: 12))!
    
    func testTaskCompatable() {
        let task1 = Task(title: "A", date: day1, time: 30)
        let task2 = Task(title: "A", date: day2, time: 30)
        
        XCTAssertTrue(task1 < task2)
    }
    
    func testTaskComparable2() {
        let t1 = Task(title: "AA", date: day1, time: 30)
        let t2 = Task(title: "AA", date: day2, time: 30)
        let t3 = Task(title: "AA", date: day3, time: 30)
        
        let input = [t1, t3, t2]
        
        let results = input.sorted()
        
        let expected = [t1, t2, t3]
        
        XCTAssertEqual(results, expected)
    }
    
    func testTaskComparable3() {
        let t1 = Task(title: "AA", date: day1, time: 30)
        let t2 = Task(title: "AA", date: day1, time: 45)
        let t3 = Task(title: "AA", date: day2, time: 30)
        let t4 = Task(title: "AB", date: day2, time: 30)
        let t5 = Task(title: "AB", date: day2, time: 45)
        let t6 = Task(title: "BA", date: day3, time: 60)
        let t7 = Task(title: "BB", date: day3, time: 60)
        let t8 = Task(title: "BB", date: day2, time: 90)
        
        let input = [t5, t8, t1, t2, t7, t3, t6, t4]
        let expected = [t2, t1, t8, t5, t3, t4, t6, t7]
        
        XCTAssertEqual(input.count, 8, "test setup error")
        XCTAssertEqual(expected.count, 8, "test setup error")
        
        let result = input.sorted()
        
        XCTAssertEqual(result, expected)
    }
    
    func testGetTapticNotificationType() {
        XCTAssertEqual(getTapticNotificationType(eventsCount: 5, notScheduledEventsCount: 0, notOrganizedTasksCount: 0, notParsableLinesCount: 0), .success)
        
        XCTAssertEqual(getTapticNotificationType(eventsCount: 0, notScheduledEventsCount: 0, notOrganizedTasksCount: 0, notParsableLinesCount: 0), .warning)
        
        XCTAssertEqual(getTapticNotificationType(eventsCount: 3, notScheduledEventsCount: 2, notOrganizedTasksCount: 0, notParsableLinesCount: 0), .warning)
        
        XCTAssertEqual(getTapticNotificationType(eventsCount: 0, notScheduledEventsCount: 0, notOrganizedTasksCount: 5, notParsableLinesCount: 0), .error)
        
        XCTAssertEqual(getTapticNotificationType(eventsCount: 0, notScheduledEventsCount: 0, notOrganizedTasksCount: 0, notParsableLinesCount: 5), .error)
        
        XCTAssertEqual(getTapticNotificationType(eventsCount: 0, notScheduledEventsCount: 5, notOrganizedTasksCount: 0, notParsableLinesCount: 0), .error)
    }
}
