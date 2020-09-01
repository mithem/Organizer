//
//  MarkdownParser.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
// Inspired by Checklist (my own project, though)

import Foundation
import EventKit

/// Parser for Markdown as provided by Thing's Share Sheet
struct MarkdownParser {
    
    static let _emojiRegex = NSRegularExpression("[\\U00010000-\\U0010FFFF]")
    static let _singleWordChar = #"[\w\s\d@ß?=!\^°\"\'§\$,&\.%\/\(\)]"#
    static let taskRegex = NSRegularExpression(#"- (?<date>\d\d\.\d\d\.\d\d\d\d )?\[[+ x]?\] (?<title>"# + _singleWordChar + #"+)"#)
    static let taskNameRegex = NSRegularExpression(#"^ ?((?<n1>\d\d?)(?<u>h|(min|m))(( )?(?<n2>\d\d?)(min|m))?)? ?(?<title>"# + _singleWordChar + #"*)$"#)
    
    func parseTasks(from text: String, progressCallback: (Float) -> Void) -> (tasks: [Task], notParsableLines: [String]) {
        progressCallback(0.0)
        let text = MarkdownParser._emojiRegex.stringByReplacingMatches(in: text, range: NSRange(location: 0, length: text.count), withTemplate: "")
        
        var tasks = [Task]()
        var notParsableLines = [String]()
        let lines = text.split(separator: "\n").map({String($0)})
        var lineIdx = 0
        for line in lines {
            guard let result = MarkdownParser.taskRegex.firstMatch(in: line, range: NSRange(location: 0, length: line.count)) else { notParsableLines.append(line); continue }
            var nsRange = result.range(withName: "title")
            guard let range = Range(nsRange) else { notParsableLines.append(line); continue }
            let title = String(line[range])
            nsRange = result.range(withName: "date")
            guard let dateRange = Range(nsRange) else { notParsableLines.append(line); continue }
            guard let taskDate = _parseDate(from: String(line[dateRange])) else { notParsableLines.append(line); continue }
            let timeAndTitle = _getTimeInterval(from: title)
            guard let newTime = timeAndTitle.time else { notParsableLines.append(line); continue }
            guard let newTitle = timeAndTitle.title else { notParsableLines.append(line); continue }
            let task = Task(title: newTitle, date: taskDate, time: newTime)
            tasks.append(task)
            lineIdx += 1
            progressCallback(Float(lineIdx / lines.count))
        }
        
        progressCallback(1.0)
        return (tasks: tasks, notParsableLines: notParsableLines)
    }
    
    func _parseDate(from: String) -> Date? {
        let l = from.replacingOccurrences(of: " ", with: "").split(separator: ".")
        guard l.count == 3 else { return nil }
        var dateComponents = DateComponents()
        
        dateComponents.nanosecond = 0
        dateComponents.minute = 0
        dateComponents.hour = 12
        
        dateComponents.day = Int(l[0])
        dateComponents.month = Int(l[1])
        dateComponents.year = Int(l[2])
        
        let date = Calendar.current.date(from: dateComponents)
        return date
    }
    
    func _getTimeInterval(from taskName: String) -> (time: TimeInterval?, title: String?) {
        guard let result = MarkdownParser.taskNameRegex.firstMatch(in: taskName, range: NSRange(location: 0, length: taskName.count)) else { return (nil, nil) }
        guard let n1Range = Range(result.range(withName: "n1")) else { return (nil, nil) }
        guard let uRange = Range(result.range(withName: "u")) else { return (nil, nil) }
        guard let titleRange = Range(result.range(withName: "title")) else { return (nil, nil) }
        
        guard let n1 = Double(String(taskName[n1Range])) else { return (nil, nil) }
        let u = String(taskName[uRange])
        
        var timeInterval: TimeInterval
        
        if u == "h" {
            timeInterval = 3600 * n1
        } else if u == "min" || u == "m" {
            timeInterval = 60 * n1
        } else {
            NSLog("Received unsupported unit: \(u)")
            return (nil, nil)
        }
        
        if let n2Range = Range(result.range(withName: "n2")) {
            guard let n2 = Double(String(taskName[n2Range])) else { return (nil, nil) }
            timeInterval += n2 * 60
        }
        
        let title = String(taskName[titleRange])
        
        return (timeInterval, title)
    }
}
