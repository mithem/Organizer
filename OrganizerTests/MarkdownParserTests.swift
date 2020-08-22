//
//  MarkdownParserTests.swift
//  OrganizerTests
//
//  Created by Miguel Themann on 22.08.20.
//

import XCTest
import EventKit
@testable import Organizer

class MarkdownParserTests: XCTestCase {
    let parser = MarkdownParser()
    
    func testTaskRegex() {
        var string: String
        var result: NSTextCheckingResult?
        var range: NSRange {
            NSRange(location: 0, length: string.count)
        }
        
        string = "- [+] Example !task 1"
        result = MarkdownParser.taskRegex.firstMatch(in: string, range: range)
        XCTAssertNotNil(result, "No match found.")
        if let result = result {
            XCTAssertEqual(string[Range(result.range(at: 2))!], "Example !task 1")
        }
        
        string = "- [] Another task🚀"
        result = MarkdownParser.taskRegex.firstMatch(in: string, range: range)
        XCTAssertNotNil(result, "No match found.")
        if let result = result {
            XCTAssertEqual(string[Range(result.range(at: 2))!], "Another task")
        }
    }
    
    func testTaskNameRegex() {
        var string: String
        var result: NSTextCheckingResult?
        var range: NSRange {
            NSRange(location: 0, length: string.count)
        }
        func at(_ i: Int) -> String? {
            let r = result!.range(at: i)
            guard let range = Range(r) else { return nil }
            return String(string[range])
        }
        
        string = "2h15min hello !there"
        result = MarkdownParser.taskNameRegex.firstMatch(in: string, range: range)
        XCTAssertNotNil(result, "No match found.")
        if result != nil {
            let n1 = at(2)
            let n2 = at(7)
            let u = at(3)
            
            XCTAssertNotNil(n1)
            XCTAssertNotNil(n2)
            XCTAssertNotNil(u)
            
            XCTAssertEqual(n1, "2")
            XCTAssertEqual(n2, "15")
            XCTAssertEqual(u, "h")
        }
        
        string = " 2h 15m hello !there"
        result = MarkdownParser.taskNameRegex.firstMatch(in: string, range: range)
        XCTAssertNotNil(result, "No match found.")
        if result != nil {
            let n1 = at(2)
            let n2 = at(7)
            let u = at(3)
            
            XCTAssertNotNil(n1)
            XCTAssertNotNil(n2)
            
            XCTAssertEqual(n1, "2")
            XCTAssertEqual(n2, "15")
            XCTAssertEqual(u, "h")
        }
        
        string = "45min hello there"
        result = MarkdownParser.taskNameRegex.firstMatch(in: string, range: range)
        XCTAssertNotNil(result, "No match found.")
        if result != nil {
            let n1 = at(2)
            let n2 = at(7)
            let u = at(3)
            
            XCTAssertNotNil(n1)
            XCTAssertNil(n2)
            XCTAssertNotNil(u)
            
            XCTAssertEqual(n1, "45")
            XCTAssertEqual(u, "min")
        }
        
        string = "5hhello there"
        result = MarkdownParser.taskNameRegex.firstMatch(in: string, range: range)
        XCTAssertNotNil(result, "No match found.")
        if result != nil {
            let n1 = at(2)
            let n2 = at(7)
            let u = at(3)
            
            XCTAssertNotNil(n1)
            XCTAssertNil(n2)
            XCTAssertNotNil(u)
            
            XCTAssertEqual(n1, "5")
            XCTAssertEqual(u, "h")
        }
    }
    
    func testGetFuncInterval() {
        XCTAssertEqual(parser._getTimeInterval(from: " 4h 25m hello there!").time, 15_900)
        XCTAssertEqual(parser._getTimeInterval(from: "4h30min hello there!").time, 16_200)
        XCTAssertEqual(parser._getTimeInterval(from: " 4hhello there!").time, 14_400)
        XCTAssertEqual(parser._getTimeInterval(from: "1mhello there!").time, 60)
        XCTAssertEqual(parser._getTimeInterval(from: "2minhello there!").time, 120)
        
        XCTAssertEqual(parser._getTimeInterval(from: "4h 45min hello again").title, "hello again")
        XCTAssertEqual(parser._getTimeInterval(from: "4h 45min hello, again!").title, "hello, again!")
    }
    
    func testParseDateFromString() {
        let input = ["01.01.2001", "01.01.1970", "31.12.2020", "22.08.2020"]
        let expectedComponents = [DateComponents(year: 2001, month: 1, day: 1), DateComponents(year: 1970, month: 1, day: 1), DateComponents(year: 2020, month: 12, day: 31), DateComponents(year: 2020, month: 8, day: 22)]
        for i in 0..<input.count {
            XCTAssertEqual(parser._parseDate(from: input[i]), Calendar.current.date(from: expectedComponents[i]))
        }
    }
    
    func testParseTasks() {
        let input = """
- [ ] hello
- [+] (22.08.2020) 1h clean the room
- [x] (22.08.2020) 0h30min another test!
- [] (22.08.2020) 5m Yet& another🚀 .task%
"""
        let day = Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 22))!
        
        let expected = [Task(title: "clean the room", date: day, time: 3600), Task(title: "another test!", date: day, time: 1800), Task(title: "Yet& another .task%", date: day, time: 300)]
        
        let results = parser.parseTasks(from: input)
        XCTAssertEqual(results, expected)
    }
}
